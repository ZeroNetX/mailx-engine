import '../imports.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key? key,
    required this.currentMsg,
  }) : super(key: key);

  final Message currentMsg;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            currentMsg.subject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (currentMsg.from.isNotEmpty)
            Text(
              "From : ${currentMsg.from}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              "To : ${currentMsg.to}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          Text(
            currentMsg.body,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ).paddingOnly(left: 20.0),
    );
  }
}
