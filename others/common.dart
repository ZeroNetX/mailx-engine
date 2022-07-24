import '../imports.dart';

const admin = "1HELLoE3sFD9569CLCbHEAVqvqV7U2Ri9d";
const site = "1MaiLX6j5MSddyu8oh5CxxGrhMcSmRo6N8";

late Database db;
late StoreRef store;

void init() async {
  db = await getDatabase();
  store = StoreRef.main();
  await ZeroNet.instance.connect(site);
  final siteInfo = (await ZeroNet.instance.siteInfoFuture()).siteInfo;
  siteController.updateSiteInfo(siteInfo);
  if (siteInfo.certUserId?.isNotEmpty ?? false) {
    siteController.isUserLoggedIn.value = true;
    await loadMessages();
    await loadMessagesSent();
    await getUsernames(siteController.contactAddrs);
  }
}

loadMessages() async {
  var res = await decrypyNewSecrets();
  if (res != null && res.isNotEmpty) {
    var valid = res.where((element) => element.aesKey != null).toList();
    decryptNewMsgs(valid);
  }
}

loadMessagesSent() async {
  decryptMsgsSent();
}

decryptNewMsgs(List<SecretResult> msgs) async {
  final addrs = msgs.map((element) => element.directory).toList().join('","');
  final where = 'WHERE directory IN ("$addrs")';
  final query = """
			SELECT * FROM message
			LEFT JOIN json USING (json_id)
			$where
			ORDER BY date_added ASC
		""";
  final res = await ZeroNet.instance.dbQueryFuture(query, {});
  if (res.result != null && res.result.isNotEmpty) {
    final List<EncryptedMsg> messages = List.from(
      res.result.map((element) => EncryptedMsg.fromJson(element)),
    );
    final aesKeys = msgs.map((element) => element.aesKey!).toList();
    final encrytedMsgs = messages.map((e) => e.encrypted.split(',')).toList();
    final aesDecryptRes = await ZeroNet.instance.aesDecryptFuture(
      null,
      null,
      null,
      encryptedTexts: encrytedMsgs,
      keys: aesKeys,
    );
    if (aesDecryptRes.result != null && aesDecryptRes.result is List) {
      for (var i = 0; i < aesDecryptRes.result.length; i++) {
        final msg = aesDecryptRes.result[i];
        if (msg != null) {
          messages[i].body = msg;
          siteController.addMessageReceived(messages[i]);
          var isRead = await store.record('inbox#${messages[i].dateAdded}').get(
                db,
              );
          if (isRead == true) {
            siteController.messagesReceivedRead.addIf(
              !siteController.messagesReceivedRead
                  .contains(messages[i].dateAdded),
              messages[i].dateAdded,
            );
          }
        }
      }
    }
  }
}

decryptMsgsSent() async {
  final authAddr = siteController.siteInfo.value.authAddress!;
  final where = 'WHERE directory = "$authAddr"';
  final query = """
			SELECT * FROM message
			LEFT JOIN json USING (json_id)
			$where
			ORDER BY date_added ASC
		""";
  final res = await ZeroNet.instance.dbQueryFuture(query);
  if (res.result != null && res.result.isNotEmpty) {
    final List<EncryptedMsg> messages = List.from(
      res.result.map((element) => EncryptedMsg.fromJson(element)),
    );
    final user = User("", "");
    await user.loadData(authAddr);
    final secrets = await user.getDecryptedSecretsSent();
    final encrytedMsgs = messages.map((e) => e.encrypted.split(',')).toList();
    final aesKeys = secrets?.values
            .map((key) => (key as String).split(':').last)
            .toList() ??
        [];
    final aesDecryptRes = await ZeroNet.instance.aesDecryptFuture(
      null,
      null,
      null,
      encryptedTexts: encrytedMsgs,
      keys: aesKeys,
    );
    if (aesDecryptRes.result != null && aesDecryptRes.result is List) {
      for (var i = 0; i < aesDecryptRes.result.length; i++) {
        final msg = aesDecryptRes.result[i];
        if (msg != null) {
          messages[i].body = msg;
          siteController.addMessageSent(messages[i]);
        }
      }
    }
  }
}

Future<List<SecretResult>?> decrypyNewSecrets([
  Map<String, dynamic> lastSecrets = const {},
]) async {
  var lastParsed = 0;
  var knownAddresses = [];
  for (var i = 0; i < lastSecrets.length; i++) {
    lastParsed = max(lastParsed, lastSecrets['user_last_parsed']);
    knownAddresses.add(lastSecrets['user_address']);
  }
  String where;
  if (knownAddresses.isNotEmpty) {
    assert(false);
    where = '';
  } else {
    where = '';
  }
  var query = """
			SELECT * FROM secret
			LEFT JOIN json USING (json_id)
			$where
			ORDER BY date_added ASC
		""";
  var res = await ZeroNet.instance.dbQueryFuture(query, {});
  if (res.result is List) {
    var rows = List<SecretResult>.from(
      res.result
          .map(
            (e) => SecretResult.fromJson(e),
          )
          .toList(),
    );
    var secrets = rows.map((e) => e.encrypted).toList();
    var contacts = rows.map((e) => e.directory).toList();
    siteController.addContacts(contacts);
    var aesKeys = await ZeroNet.instance.eciesDecryptFuture(secrets);
    if (aesKeys.result != null && aesKeys.result is List) {
      for (var i = 0; i < aesKeys.result.length; i++) {
        rows[i].aesKey = aesKeys.result[i];
      }
    }
    return rows;
  }
  return null;
}

void getArchived() async {
  final message = await ZeroNet.instance.fileGetFuture('data/archived.json');
  if (message.result == null) {
    return;
  } else {
    var res = message.result;
    print(res);
  }
}

Future<void> getUsernames(List<String> addrs) async {
  var query = """
			SELECT directory, value AS cert_user_id
			FROM json
			LEFT JOIN keyvalue USING (json_id)
			WHERE ? AND file_name = 'content.json' AND key = 'cert_user_id'
		""";
  final message = await ZeroNet.instance.dbQueryFuture(query, {
    "directory": addrs,
  });
  if (message.result == null) {
    return;
  } else {
    var res = message.result;
    for (var i = 0; i < res?.length; i++) {
      siteController.contacts[res[i]['directory']] = res[i]['cert_user_id'];
    }
  }
}
