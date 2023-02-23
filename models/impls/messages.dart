import '../../imports.dart';
import '../interfaces/secret_store.dart';
import '../profile.dart';

class MessageStore extends SecretStoreInterface {
  final SecretStoreMap dataMap = {
    'secrets_sent': "",
    'secret': {},
    'messages': {},
  };

  MessageStore({
    required String authAddress,
  }) : super(authAddress, 'data.json') {
    super.data = dataMap;
  }

  Future<void> unsendMessage(Profile profile, String msg) async {
    await loadData();
    // final secret = await getSecret(profile.btcAddress, profile.publicKey);
    // final request = json.encode({'msg': msg, 'to': profile.id});
    // final dec = await ZeroNet.instance.aesEncryptFuture(
    //   request,
    //   key: secret,
    // );
    // addMessage(List<String>.from(dec.result));
    await saveData();
  }

  Future<void> sendMessage(Profile profile, Mail msg) async {
    await loadData();
    final secret = await getSecret(profile.btcAddress, profile.publicKey);
    final message = json.encode(msg.toJson);
    final dec = await ZeroNet.instance.aesEncryptFuture(
      message,
      key: secret,
    );
    addMessage(List<String>.from(dec.result));
    await saveData();
  }

  bool addMessage(List<String> encrypted) {
    var index = getNewIndex('message');
    final _ = encrypted[0];
    final iv = encrypted[1];
    final encryptedMsg = encrypted[2];
    if (data['message'].keys.isEmpty) {
      data['message'] = {"$index": "$iv,$encryptedMsg"};
    } else {
      data['message']["$index"] = "$iv,$encryptedMsg";
    }

    return true;
  }
}
