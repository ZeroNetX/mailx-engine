import '../imports.dart';

void showZeroNetxDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final mediaSize = MediaQuery.of(context).size;

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            child: SizedBox(
              height:
                  (mediaSize.width > mediaSize.height && mediaSize.height < 400)
                      ? mediaSize.height
                      : 470,
              width: (mediaSize.width * 0.4) < 250 ? mediaSize.width - 40 : 450,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.cancel,
                        //color: Color(0xff6d4aff),
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                            // color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          'Select account you want to use in this application',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: mediaSize.height > 500 ? 300 : 160,
                          child: const CertificatesList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class CertificatesList extends StatefulWidget {
  const CertificatesList({super.key});

  @override
  State<CertificatesList> createState() => _CertificatesListState();
}

class _CertificatesListState extends State<CertificatesList> {
  late PromptResult res;
  UserID? selectedUserId;
  List<UserID> userIds = [];

  void getUserId() async {
    res = await ZeroNet.instance.certSelectFuture(
      accepted_domains: ['zeroid.bit'],
    );
    userIds = extractCertSelectDomains(res);
    final active = userIds.where((element) => element.active == true);
    if (active.isNotEmpty) {
      selectedUserId = active.first;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              UserID userId = userIds.elementAt(index);
              if (userId.domain.isEmpty) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  selectedUserId = userId;
                  setState(() {});
                },
                child: CertificatesListItem(
                  userID: userId,
                  selected: selectedUserId == userId,
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (selectedUserId != null)
                if (selectedUserId!.domain.isNotEmpty && selectedUserId!.active)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll(
                        Colors.redAccent,
                      ),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await ZeroNet.instance.respondFuture(
                        (res.value as Notification).id,
                        '',
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    selectedUserId?.registered ?? true
                        ? Colors.indigo
                        : Colors.green,
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: (selectedUserId?.domain.isEmpty ?? true)
                    ? null
                    : selectedUserId!.active
                        ? null
                        : !selectedUserId!.registered
                            ? () {}
                            : () async {
                                Navigator.pop(context);
                                await ZeroNet.instance.respondFuture(
                                  (res.value as Notification).id,
                                  selectedUserId!.domain,
                                );
                              },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 30,
                  ),
                  child: Text(
                    selectedUserId?.registered ?? true
                        ? 'Continue'
                        : 'Register',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CertificatesListItem extends StatelessWidget {
  const CertificatesListItem({
    required this.userID,
    required this.selected,
    super.key,
  });
  final UserID userID;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const Color blueColor = Colors.indigo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? blueColor : Colors.transparent,
              border: Border.all(color: blueColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.fade,
                  text: TextSpan(
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    text: "Domain : ",
                    children: [
                      TextSpan(
                        text: userID.domain,
                        style: TextStyle(
                          color: selected ? Colors.white : blueColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    text: "User ID  : ",
                    children: [
                      TextSpan(
                        text: userID.username.isNotEmpty
                            ? userID.username.replaceAll(
                                '@${userID.domain}',
                                '',
                              )
                            : 'Yet to be Registered',
                        style: TextStyle(
                          color: selected ? Colors.white : blueColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
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
