import '../imports.dart';

GlobalKey<UserIdSuggestionsListState> userIdSortingKey =
    GlobalKey<UserIdSuggestionsListState>();
TextEditingController toTextCtrl = TextEditingController();
bool showSuggestion = false;

class NewMessageComposer extends StatelessWidget {
  const NewMessageComposer({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController subjTextCtrl = TextEditingController();
    TextEditingController bodyCtrl = TextEditingController();
    return LayoutBuilder(
      builder: (layoutContext, costrains) {
        final deviceSize = MediaQuery.of(layoutContext).size;
        final size = Size(
          deviceSize.width *
              (deviceSize.width > 800
                  ? deviceSize.width > 1200
                      ? 0.45
                      : 0.6
                  : 0.75),
          deviceSize.height * 0.8,
        );
        final showComposer = siteController.showNewMessageComposer.value;
        return Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                alignment: Alignment.bottomCenter,
                curve: decelerateEasing,
                duration: const Duration(milliseconds: 400),
                width: size.width,
                height: siteController.showNewMessageComposer.value
                    ? size.height
                    : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: showComposer
                      ? const [
                          BoxShadow(
                            blurRadius: 1,
                            color: Colors.black38,
                            spreadRadius: 1,
                            offset: Offset(2, 2),
                          )
                        ]
                      : [],
                ),
                child: Visibility(
                  visible: siteController.showNewMessageComposer.value,
                  child: FutureBuilder(
                    future: Future.delayed(
                      const Duration(milliseconds: 350),
                    ),
                    builder: (context, snp) {
                      if (snp.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      final showComposer =
                          siteController.showNewMessageComposer.value;
                      return Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xff1b1340),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            height: 60,
                            child: Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                  onPressed: siteController.toggleNewMsgDialog,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ).paddingOnly(right: 10)
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    MessageFields(
                                      size: size,
                                      textType: 'From',
                                      hintText: siteController
                                              .siteInfo.value?.certUserId ??
                                          '',
                                    ),
                                    MessageFields(
                                      size: size,
                                      textType: 'To',
                                      hintText: 'Email Address',
                                      textController: toTextCtrl,
                                    ),
                                    MessageFields(
                                      size: size,
                                      textType: 'Subject',
                                      hintText: 'Subject',
                                      textController: subjTextCtrl,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Builder(builder: (context) {
                                        return Container(
                                          height: size.height > 600
                                              ? size.height * 0.45
                                              : size.height * 0.25,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black38,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: TextField(
                                            onTap: () {
                                              if (showSuggestion) {
                                                showSuggestion = false;
                                                userIdSortingKey.currentState!
                                                    .refresh();
                                              }
                                            },
                                            cursorColor: Colors.black,
                                            maxLines: 1000,
                                            controller: bodyCtrl,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: 'Enter message',
                                              fillColor: Colors.white,
                                              hoverColor: Colors.transparent,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                const MaterialStatePropertyAll(
                                              Color(0xff6d4aff),
                                            ),
                                            shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final Mail mail = Mail(
                                              subjTextCtrl.text,
                                              bodyCtrl.text,
                                              '',
                                              toTextCtrl.text,
                                            );
                                            Profile? profile =
                                                await getProfileFromUserId(
                                                    toTextCtrl.text);
                                            // siteController
                                            //     .profileContacts.values
                                            //     .firstWhere(
                                            //   (element) =>
                                            //       element.id == toTextCtrl.text,
                                            // );

                                            siteController.user.sendMessage(
                                              profile!,
                                              mail,
                                            );
                                            subjTextCtrl.clear();
                                            bodyCtrl.clear();
                                            toTextCtrl.clear();
                                            siteController.toggleNewMsgDialog();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 16,
                                            ),
                                            child: Text('Send'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                UserIdSuggestionsList(
                                  size: size,
                                  key: userIdSortingKey,
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.15,
              )
            ],
          );
        });
      },
    );
  }
}

class UserIdSuggestionsList extends StatefulWidget {
  const UserIdSuggestionsList({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<UserIdSuggestionsList> createState() => UserIdSuggestionsListState();
}

class UserIdSuggestionsListState extends State<UserIdSuggestionsList> {
  List<String> userIdsList = [];
  List<String> sortedUserIds = [];
  void loadUserIds() async {
    userIdsList = await getUsernames([]);
    sortedUserIds.addAll(userIdsList);
    if (mounted) {
      setState(() {
        sortedUserIds;
      });
    }
  }

  void sortUserIds(String pattern) {
    sortedUserIds.clear();
    for (var id in userIdsList) {
      if (id.startsWith(pattern)) {
        sortedUserIds.add(id);
      }
    }
    setState(() {});
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (userIdsList.isEmpty) {
      loadUserIds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: showSuggestion
          ? SizedBox(
              height: widget.size.height * 0.43,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 0,
                    ),
                    child: Container(
                      height: widget.size.height * 0.25,
                      width: widget.size.width * 0.7,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 2,
                              spreadRadius: 2,
                              color: Colors.black26,
                              offset: Offset(-2, 2),
                            )
                          ]),
                      child: ListView.builder(
                        itemCount: sortedUserIds.length,
                        itemBuilder: (context, index) {
                          String item = sortedUserIds.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: TextButton(
                              style: const ButtonStyle(
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () {
                                toTextCtrl.text = item;
                                showSuggestion = false;
                                setState(() {});
                              },
                              child: SizedBox(
                                width: widget.size.width * 0.55,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}

class MessageFields extends StatelessWidget {
  const MessageFields({
    super.key,
    required this.size,
    required this.textType,
    required this.hintText,
    this.textController,
  });

  final Size size;
  final String textType;
  final String hintText;
  final TextEditingController? textController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size.width * 0.18,
          child: Text(
            textType,
            style: const TextStyle(
              color: Color(0xff1b1340),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: size.width * 0.65,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.black26,
              ),
            ),
          ),
          child: textType == 'From'
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    hintText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : TextField(
                  onTap: () {
                    if (textType == "To") {
                      showSuggestion = true;
                      userIdSortingKey.currentState!.refresh();
                    } else {
                      showSuggestion = false;
                      userIdSortingKey.currentState!.refresh();
                    }
                  },
                  cursorColor: Colors.black,
                  controller: textController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: textType == 'Subject'
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                  onChanged: textType == 'To'
                      ? (value) {
                          userIdSortingKey.currentState!.sortUserIds(value);
                        }
                      : (_) {},
                  decoration: InputDecoration(
                    hintText: hintText,
                    fillColor: Colors.white,
                    hoverColor: Colors.transparent,
                    filled: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
