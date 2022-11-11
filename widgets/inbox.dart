import '../imports.dart';

class InboxMessageList extends StatelessWidget {
  const InboxMessageList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var msgs = siteController.messagesReceived;
      msgs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return ListView.builder(
        controller: ScrollController(),
        shrinkWrap: false,
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          var msg = msgs[index];
          var from = siteController.contacts[msg.directory]!.replaceAll(
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
              var isRead = await store.record('inbox#${msg.dateAdded}').get(db);
              if (isRead == null || isRead == false) {
                await store.record('inbox#${msg.dateAdded}').put(db, true);
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
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.primaryColor
                        : const Color(0xFFF5F4F2),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFe5e4e1),
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            from[0].toUpperCase(),
                          ),
                        ),
                      ).paddingSymmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            from,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : !isRead
                                      ? Colors.black
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subject,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
}
