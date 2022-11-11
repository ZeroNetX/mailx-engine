import '../imports.dart';

class SentMessageList extends StatelessWidget {
  const SentMessageList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var msgs = siteController.messagesSent;
      msgs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return ListView.builder(
        controller: ScrollController(),
        shrinkWrap: false,
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          var message = Mail.fromJson(json.decode(msgs[index].body));
          var to = message.to;
          String subject = message.subject;
          return InkWell(
            onTap: () {
              siteController.currentMessage.value = message;
            },
            child: Obx(
              () {
                final isSelected =
                    siteController.currentMessage.value == message;
                return MessageListItem(
                  isSelected: isSelected,
                  participant: to,
                  isRead: false,
                  subject: subject,
                );
              },
            ),
          );
        },
      );
    });
  }
}
