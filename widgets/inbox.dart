import '../imports.dart';

class InboxMessageList extends StatelessWidget {
  const InboxMessageList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var msgs = siteController.messagesReceived.value;
      var _ = siteController.profileContacts.length;
      msgs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return ListView.builder(
        controller: ScrollController(),
        shrinkWrap: false,
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          var msg = msgs[index];
          final profile = siteController.profileContacts[msg.directory];
          if (profile == null) {
            return const SizedBox();
          }

          var from = profile.id.replaceAll(
            '@zeroid.bit',
            '',
          );
          var message = Mail.fromJson(json.decode(msg.body), from: from);
          String subject = message.subject;
          if (subject.isEmpty) {
            subject = 'No Subject';
          } else if (subject.length > 38) {
            subject = '${subject.substring(0, 38)}...';
          }
          return InkWell(
            onTap: () async {
              var isRead = kIsWeb
                  ? true
                  : await store.record('inbox#${msg.dateAdded}').get(db!);
              if (isRead == null || isRead == false) {
                await store.record('inbox#${msg.dateAdded}').put(db!, true);
              } else {
                siteController.messagesReceivedRead.addIf(
                  !siteController.messagesReceivedRead.contains(msg.dateAdded),
                  msg.dateAdded,
                );
              }
              siteController.currentMessage.value = message;
            },
            child: Obx(
              () {
                final isSelected =
                    siteController.currentMessage.value == message;
                final isRead = siteController.messagesReceivedRead.contains(
                  msg.dateAdded,
                );
                return MessageListItem(
                  isSelected: isSelected,
                  participant: from,
                  isRead: isRead,
                  subject: subject,
                  epoch: msgs[index].dateAdded,
                );
              },
            ),
          );
        },
      );
    });
  }
}
