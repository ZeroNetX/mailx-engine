import '../imports.dart';

class MessageListItem extends StatelessWidget {
  const MessageListItem({
    Key? key,
    required this.isSelected,
    required this.participant,
    required this.isRead,
    required this.subject,
  }) : super(key: key);

  final bool isSelected;
  final String participant;
  final bool isRead;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isSelected ? context.theme.primaryColor : const Color(0xFFF5F4F2),
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
                participant[0].toUpperCase(),
              ),
            ),
          ).paddingSymmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : !isRead
                            ? Colors.black
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  subject,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
