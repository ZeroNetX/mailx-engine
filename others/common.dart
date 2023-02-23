import '../imports.dart';
import '../models/impls/messages.dart';
import '../models/profile.dart';

const admin = "1HELLoE3sFD9569CLCbHEAVqvqV7U2Ri9d";
const site = "1MaiLX6j5MSddyu8oh5CxxGrhMcSmRo6N8";

late Database? db;
late StoreRef store;

void init() async {
  db = await getDatabase();
  store = StoreRef.main();
  await ZeroNet.instance.connect(site, onEventMessage: onMessage);
  await ZeroNet.instance.channelJoinFuture(['siteChanged']);
  final siteInfoResult = (await ZeroNet.instance.siteInfoFuture());
  if (siteInfoResult.isMsg) {
    var siteInfo = siteInfoResult.message!.siteInfo;
    siteController.updateSiteInfo(siteInfo);
    if (siteInfo.certUserId?.isNotEmpty ?? false) {
      siteController.isUserLoggedIn.value = true;
      siteController.user = MessageStore(
        siteInfo.authAddress!,
      );
      await loadMessages();
      await loadMessagesSent();
      await getUsernames(siteController.contactAddrs);
    }
  }
}

void onMessage(message) {
  var msg = jsonDecode(message);
  var msg2 = msg['params'];
  if (msg2 is Map) {
    if (msg2['event'] is List) {
      final event = msg2['event'];

      final name = event[0];
      final param = event[1];

      if (name == 'file_done') {
        var path = param.toString();

        var pattern = 'data/users/';

        if (path.startsWith('${pattern}1') && path.endsWith('.json')) {
          debugPrint('User Data Changed');
          final userFile = path.replaceFirst(pattern, '');
          final dataOrContentJsonFile =
              userFile.replaceFirst(RegExp(r'1\w+'), '');
          if (dataOrContentJsonFile == "/data.json") {}
        }
      } else {
        debugPrint('Event Message : $name :: $param');
      }
    } else if (msg['cmd'] == 'peerReceive') {}
  } else {}
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
  if (res.isMsg && res.message!.result.isNotEmpty) {
    final List<EncryptedMsg> messages = List.from(
      res.message!.result.map((element) => EncryptedMsg.fromJson(element)),
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
          var isRead = kIsWeb
              ? false
              : await store.record('inbox#${messages[i].dateAdded}').get(
                    db!,
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

// to decrypt messages sent

decryptMsgsSent() async {
  final authAddr = siteController.siteInfo.value!.authAddress!;
  final where = 'WHERE directory = "$authAddr"';
  final query = """
			SELECT * FROM message
			LEFT JOIN json USING (json_id)
			$where
			ORDER BY date_added ASC
		""";
  final res = await ZeroNet.instance.dbQueryFuture(query);
  if (res.isMsg && res.message!.result.isNotEmpty) {
    final List<EncryptedMsg> messages = List.from(
      res.message!.result.map((element) => EncryptedMsg.fromJson(element)),
    );

    await siteController.user.loadData();
    final secrets = await siteController.user.getDecryptedSecretsSent();
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
  } else {}
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
  if (res.isMsg && res.message!.result is List) {
    var rows = List<SecretResult>.from(
      res.message!.result
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
  if (!message.isMsg) {
    return;
  } else {
    var res = message.message!.result;
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
  final publicKeysList = await ZeroNet.instance.fileQueryFuture(
    'data/users/*/data.json',
    query: 'publickey',
  );

  if (!message.isMsg) {
    return;
  } else {
    var res = message.message!.result;
    for (var i = 0; i < res?.length; i++) {
      final btcAddr = res[i]['directory'];
      final publicKey = (publicKeysList.result as List).firstWhere(
        (element) => element['inner_path'] == btcAddr,
      );

      siteController.profileContacts[btcAddr] = Profile(
        btcAddress: btcAddr,
        publicKey: publicKey['value'],
        id: res[i]['cert_user_id'],
      );
    }
  }
}
