import 'package:zeromailx/mailx-engine/models/impls/messages.dart';

import '../imports.dart';
import '../models/profile.dart';

final siteController = SiteVarController();

class SiteVarController extends GetxController {
  final currentRoute = Route.inbox.obs;
  final siteInfo = Rx<SiteInfo?>(null);
  final isUserLoggedIn = false.obs;
  final showNewMessageComposer = false.obs;
  final contactAddrs = <String>[].obs;
  // final contacts = <String, String>{}.obs;
  final profileContacts = <String, Profile>{}.obs;
  final messagesReceived = <EncryptedMsg>[].obs;
  final messagesSent = <EncryptedMsg>[].obs;
  final messagesReceivedRead = <int>[].obs;
  final currentMessage = Mail.empty().obs;
  late MessageStore user;
  final routes = [
    Route.inbox,
    Route.outbox,
    // Route.contacts,
    // Route.allMail,
  ].obs;

  void updateRoute(Route route) {
    currentRoute.value = route;
  }

  void resetCurrentMessage() {
    currentMessage.value = Mail.empty();
  }

  void addContact(String contact) {
    contactAddrs.add(contact);
  }

  void addContacts(List<String> contacts_) {
    contactAddrs.addAll(contacts_);
  }

  void addMessagesReceived(List<EncryptedMsg> messages) {
    messagesReceived.addAll(messages);
  }

  void addMessageReceived(EncryptedMsg message) {
    messagesReceived.add(message);
  }

  void addMessagesSent(List<EncryptedMsg> messages) {
    messagesSent.addAll(messages);
  }

  void addMessageSent(EncryptedMsg message) {
    messagesSent.add(message);
  }

  void updateSiteInfo(SiteInfo siteInfo) {
    this.siteInfo.value = siteInfo;
  }

  void toggleNewMsgDialog() {
    siteController.showNewMessageComposer.value =
        !siteController.showNewMessageComposer.value;
  }
}
