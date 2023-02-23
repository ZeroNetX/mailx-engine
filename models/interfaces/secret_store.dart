import '../../imports.dart';

typedef SecretStoreMap = Map<String, dynamic>;

abstract class SecretStoreInterface {
  final String authAddress;
  final String fileName;

  SecretStoreInterface(
    this.authAddress,
    this.fileName,
  );

  SecretStoreMap data = {};

  String innerPath([
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

  Future<String?> _addSecret(
    Map<String, dynamic> secretsSent,
    String userAddress,
    String publicKey,
  ) async {
    final res = (await ZeroNet.instance.aesEncryptFuture("")).result;
    var key = res.first;
    if (key == null) return null;
    assert(base64.decode(key).length == 32);
    final secret = await ZeroNet.instance.eciesEncryptFuture(
      key!,
      publicKey: publicKey,
    );
    final index = getNewIndex('secret');
    if (data['secret'].keys.isEmpty) {
      data['secret'] = {"$index": secret.result};
    } else {
      data['secret']["$index"] = secret.result;
    }
    final base64Index = base64.encode(utf8.encode("$index"));
    secretsSent[userAddress] = "$base64Index:$key";
    final secretSentEncrypted = await ZeroNet.instance.eciesEncryptFuture(
      json.encode(secretsSent),
      publicKey: 0,
    );
    data['secrets_sent'] = secretSentEncrypted.result;
    return key;
  }

  Future<SecretStoreMap?> getDecryptedSecretsSent() async {
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

  Future<String?> getSecret(String userAddress, String publicKey) async {
    final secretsSent = await getDecryptedSecretsSent() ?? {};
    if (secretsSent[userAddress] == null) {
      final aesKey = await _addSecret(secretsSent, userAddress, publicKey);
      return aesKey;
    } else {
      final base64Index = secretsSent[userAddress];
      var key = base64Index.split(':').last;
      return key;
    }
  }

  Future<void> loadData() async {
    final innerPathStr = innerPath(fileName);
    final message = await ZeroNet.instance.fileGetFuture(
      innerPathStr,
      required_: false,
    );
    if (!message.isMsg) {
      return;
    } else {
      final dataLoaded = json.decode(message.message!.result);
      assert(dataLoaded is Map<String, dynamic>);
      if ((dataLoaded as Map<String, dynamic>).isNotEmpty) {
        data = dataLoaded;
      }
    }
  }

  Future<void> saveData() async {
    final innerPathStr = innerPath(fileName);
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
    final message = await ZeroNet.instance.fileWriteFuture(
      innerPathStr,
      base64.encode(encode),
    );
    if (message.isErr) {
      return;
    } else {
      final messagePublish = await ZeroNet.instance.sitePublishFuture(
        inner_path: innerPathStr,
      );
      if (messagePublish.isErr) {
        return;
      } else {
        if (messagePublish.message!.result != 'ok') {
          print(messagePublish.message!.result);
        }
        return;
      }
    }
  }
}
