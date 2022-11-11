import '../imports.dart';

class User {
  final String authAddress;
  final String publicKey;

  var data = <String, dynamic>{
    'secrets_sent': "",
    'secrets': {},
    'requests': {},
    'messages': {},
  };

  User(this.authAddress, this.publicKey);

  String innerPath(
    String authAddress, [
    String fileName = 'data.json',
  ]) =>
      'data/users/$authAddress/$fileName';

  int getNewIndex(String key) {
    var index = DateTime.now().millisecondsSinceEpoch;
    assert(index.toString().length == 13);
    var found = false;
    while (!found) {
      found = data[key][index] ?? true;
      if (!found) index++;
    }
    return index;
  }

  Future<Map<String, dynamic>?> getDecryptedSecretsSent() async {
    final secret = data['secrets_sent'];
    if (secret == null || secret.isEmpty) {
      return Future.value(null);
    }

    final msg = await ZeroNet.instance.eciesDecryptFuture(secret);
    //TODO! CHECK RESULT HERE
    var decode = json.decode(msg.result);
    assert(decode is Map);
    return decode;
  }

  bool addFriendRequest(List<String> encrypted) {
    var index = getNewIndex('requests');
    final _ = encrypted[0];
    final iv = encrypted[1];
    final encryptedMsg = encrypted[2];
    if (data['requests'].keys.isEmpty) {
      data['requests'] = {"$index": "$iv,$encryptedMsg"};
    } else
      data['requests']["$index"] = "$iv,$encryptedMsg";
    return true;
  }

  Future<String?> _addSecret(
    Map<String, dynamic> secretsSent,
    String userAddress,
  ) async {
    final aesKey = await ZeroNet.instance.aesEncryptFuture("");
    var key = aesKey.result.first;
    if (key == null) return null;
    assert(base64.decode(key).length == 32);
    final secret = await ZeroNet.instance.eciesEncryptFuture(
      key!,
      publicKey: 0,
    );
    final index = getNewIndex('secrets');
    if (data['secrets'].keys.isEmpty) {
      data['secrets'] = {index: secret.result};
    } else {
      data['secrets']["$index"] = secret.result;
    }
    secretsSent[userAddress] = base64.encode(utf8.encode('$index:$key'));
    final secretSentEncrypted = await ZeroNet.instance.eciesEncryptFuture(
      json.encode(secretsSent),
      publicKey: 0,
    );
    data['secrets_sent'] = secretSentEncrypted.result;
    return key;
  }

  Future<String?> getSecret(String userAddress) async {
    final secretsSent = await getDecryptedSecretsSent() ?? {};
    if (secretsSent[userAddress] == null) {
      final aesKey = await _addSecret(secretsSent, userAddress);
      return aesKey;
    } else {
      return secretsSent[userAddress];
    }
  }

  Future<void> loadData(String authAddress) async {
    final innerPathStr = innerPath(authAddress);
    final msgOrErr = await ZeroNet.instance.fileGetFuture(
      innerPathStr,
      required_: false,
    );
    if (!msgOrErr.isMsg) {
      return;
    } else {
      final dataLoaded = json.decode(msgOrErr.message!.result);
      assert(dataLoaded is Map);
      data = dataLoaded;
    }
  }

  Future<void> saveData(String authAddress) async {
    final innerPathStr = innerPath(authAddress);
    var innerdata = <String, dynamic>{};
    for (String key in data.keys) {
      var value = data[key];
      if (value is Map && value.keys.isNotEmpty && value.keys.first is int) {
        var innermap = <String, dynamic>{};
        for (int innerkey in value.keys) {
          innermap["$innerkey"] = value[innerkey];
        }
        innerdata[key] = innermap;
      } else {
        innerdata[key] = value;
      }
    }
    var dataToSave = innerdata;
    var encode = utf8.encode(json.encode(dataToSave));
    final msgOrErr = await ZeroNet.instance.fileWriteFuture(
      innerPathStr,
      base64.encode(encode),
    );
    if (!msgOrErr.isMsg) {
      return;
    } else {
      assert(msgOrErr.message!.result == 'ok');
      final messagePublish = await ZeroNet.instance.sitePublishFuture(
        inner_path: innerPathStr,
      );
      if (!messagePublish.isMsg) {
        return;
      } else {
        assert(messagePublish.message!.result == 'ok');
        return;
      }
    }
  }
}
