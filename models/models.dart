import '../imports.dart';

class Message {
  late String subject;
  late String body;
  late String from;
  late String to;

  Message(this.subject, this.body, this.from, this.to);

  Message.fromJson(
    Map<String, dynamic> json, {
    this.from = "",
  }) {
    subject = json['subject'];
    body = json['body'];
    to = json['to'];
  }
}

class SecretResult {
  late int dateAdded;
  late String encrypted;
  late int jsonId;
  late String directory;
  late String fileName;
  late String? aesKey;

  SecretResult(
    this.dateAdded,
    this.encrypted,
    this.jsonId,
    this.directory,
    this.fileName,
  );

  SecretResult.fromJson(Map<String, dynamic> json) {
    dateAdded = json['date_added'];
    encrypted = json['encrypted'];
    jsonId = json['json_id'];
    directory = json['directory'];
    fileName = json['file_name'];
  }

  SecretResult addKey(String? key) {
    aesKey = key;
    return this;
  }
}

class EncryptedMsg {
  late int dateAdded;
  late String encrypted;
  late int jsonId;
  late String directory;
  late String fileName;
  late String body;

  EncryptedMsg(
    this.dateAdded,
    this.encrypted,
    this.jsonId,
    this.directory,
    this.fileName,
  );

  EncryptedMsg.fromJson(Map<String, dynamic> json) {
    dateAdded = json['date_added'];
    encrypted = json['encrypted'];
    jsonId = json['json_id'];
    directory = json['directory'];
    fileName = json['file_name'];
  }

  EncryptedMsg addKey(String body) {
    this.body = body;
    return this;
  }
}

enum Route {
  inbox,
  outbox,
  contacts,
  allMail,
}

extension RouteExt on Route {
  String get label {
    switch (this) {
      case Route.inbox:
        return 'Inbox';
      case Route.outbox:
        return 'Sent';
      case Route.contacts:
        return 'Contacts';
      case Route.allMail:
        return 'All Mail';
      default:
        return 'inbox';
    }
  }

  IconData get icon {
    switch (this) {
      case Route.inbox:
        return Icons.inbox_outlined;
      case Route.outbox:
        return Icons.outbox_outlined;
      case Route.contacts:
        return Icons.people_alt_outlined;
      case Route.allMail:
        return Icons.all_inbox_outlined;
      default:
        return Icons.not_accessible;
    }
  }

  void onTap() {
    siteController.resetCurrentMessage();
    siteController.updateRoute(this);
  }
}
