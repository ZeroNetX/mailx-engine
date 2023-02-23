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
  late var res;
  int selectedIndex = 0;
  List<UserID> userIds = [];
  List<MyUserID> myUserIds = [];

  void getUserId() async {
    res = await ZeroNet.instance.certSelectFuture();
    userIds = extractCertSelectDomains(res);
    for (var obj in userIds) {
      myUserIds.add(MyUserID.fromUserId(obj));
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
            itemCount: myUserIds.length,
            itemBuilder: (context, index) {
              MyUserID userId = myUserIds.elementAt(index);
              if (userId.domain.isEmpty) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  selectedIndex = index;
                  for (var obj in myUserIds) {
                    if (obj.username == userId.username &&
                        obj.domain == userId.domain) {
                      obj.active = true;
                    } else {
                      obj.active = false;
                    }
                  }
                  setState(() {
                    userIds;
                  });
                },
                child: CertificatesListItem(
                  userID: userId,
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
          child: ElevatedButton(
            style: ButtonStyle(
              // backgroundColor: const MaterialStatePropertyAll(
              //   Color(0xff6d4aff),
              // ),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: selectedIndex == 0
                ? null
                : () async {
                    await ZeroNet.instance.respondFuture(
                      (res.value as Notification).id,
                      myUserIds[selectedIndex].domain,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class CertificatesListItem extends StatelessWidget {
  const CertificatesListItem({
    required this.userID,
    super.key,
  });
  final MyUserID userID;

  @override
  Widget build(BuildContext context) {
    const Color blueColor = true ? Colors.indigo : Color(0xff6d4aff);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: userID.active ? blueColor : Colors.transparent,
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
                      color: userID.active ? Colors.white : Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    text: "Domain : ",
                    children: [
                      TextSpan(
                        text: userID.domain,
                        style: TextStyle(
                          color: userID.active ? Colors.white : blueColor,
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
                      color: userID.active ? Colors.white : Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    text: "User Id : ",
                    children: [
                      TextSpan(
                        text: userID.username,
                        style: TextStyle(
                          color: userID.active ? Colors.white : blueColor,
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

class MyUserID {
  final String domain;
  final String username;
  bool active;

  MyUserID({
    required this.domain,
    required this.username,
    required this.active,
  });

  factory MyUserID.fromUserId(UserID userID) {
    return MyUserID(
      domain: userID.domain,
      username: userID.username,
      active: userID.active,
    );
  }
}
