import '../imports.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (ctx, cons) {
                var width = MediaQuery.of(context).size.width;
                return SidebarWidget(extended: width > 800);
              }),
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
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: NewMessageComposer(),
        )
      ],
    );
  }
}
