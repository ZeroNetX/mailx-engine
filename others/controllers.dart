import 'package:zeromailx/mailx-engine/models/impls/messages.dart';

import '../imports.dart';
import '../models/profile.dart';

final siteController = SiteVarController();

class SiteVarController extends GetxController {
  var currentRoute = Route.inbox.obs;
  var siteInfo = Rx<SiteInfo?>(null);
  var isUserLoggedIn = false.obs;
  var contactAddrs = <String>[].obs;
  // var contacts = <String, String>{}.obs;
  var profileContacts = <String, Profile>{}.obs;
  var messagesReceived = <EncryptedMsg>[].obs;
  var messagesSent = <EncryptedMsg>[].obs;
  var messagesReceivedRead = <int>[].obs;
  var currentMessage = Mail.empty().obs;
  late MessageStore user;
  var routes = [
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
}
