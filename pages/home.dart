import '../imports.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SidebarWidget(),
        Flexible(
          flex: 3,
          child: Obx(
            (() {
              final route = siteController.currentRoute.value;
              switch (route) {
                case Route.inbox:
                  return const InboxMessageList();
                case Route.outbox:
                  return const SentMessageList();
                default:
                  return Container();
              }
            }),
          ),
        ),
        Flexible(
          flex: 4,
          child: Obx(() {
            final currentMsg = siteController.currentMessage.value;
            if (currentMsg.to.isNotEmpty) {
              return MessageWidget(currentMsg: currentMsg);
            }
            return Container();
          }),
        )
      ],
    );
  }
}
