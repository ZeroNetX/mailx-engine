import '../imports.dart';

class NewMessageComposer extends StatelessWidget {
  const NewMessageComposer({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController toTextCtrl = TextEditingController();
    TextEditingController subjTextCtrl = TextEditingController();
    TextEditingController bodyCtrl = TextEditingController();
    return LayoutBuilder(
      builder: (layoutContext, costrains) {
        final size = Size(
          MediaQuery.of(layoutContext).size.width * 0.5,
          MediaQuery.of(layoutContext).size.height * 0.8,
        );

        return Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                alignment: Alignment.bottomCenter,
                curve: decelerateEasing,
                duration: const Duration(milliseconds: 400),
                width: size.width,
                height: mailUiController.showNewMessageComposer.value
                    ? size.height
                    : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: mailUiController.showNewMessageComposer.value
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
                child: FutureBuilder(
                  future: Future.delayed(
                    const Duration(milliseconds: 300),
                  ),
                  builder: (context, snp) {
                    if (snp.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity:
                          mailUiController.showNewMessageComposer.value ? 1 : 0,
                      child: Column(
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Builder(builder: (context) {
                                    return Container(
                                      height: size.height > 600
                                          ? size.height * 0.45
                                          : size.height * 0.25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black38,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        cursorColor: Colors.black,
                                        maxLines: 1000,
                                        controller: bodyCtrl,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: const InputDecoration(
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
                                    onPressed: () {
                                      final Mail mail = Mail(
                                        subjTextCtrl.text,
                                        bodyCtrl.text,
                                        '',
                                        toTextCtrl.text,
                                      );
                                      final profile = siteController
                                          .profileContacts.values
                                          .firstWhere(
                                        (element) =>
                                            element.id == toTextCtrl.text,
                                      );
                                      siteController.user
                                          .sendMessage(profile, mail);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Text('Send'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
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

class MessageFields extends StatelessWidget {
  const MessageFields(
      {super.key,
      required this.size,
      required this.textType,
      required this.hintText,
      this.textController});

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
                  cursorColor: Colors.black,
                  controller: textController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: textType == 'Subject'
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
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
