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
          String show = message.subject;
          return InkWell(
            onTap: () {
              siteController.currentMessage.value = message;
            },
            child: Obx(
              () {
                final isSelected =
                    siteController.currentMessage.value == message;
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
                            to[0].toUpperCase(),
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
                            to,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          Text(
                            show,
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
