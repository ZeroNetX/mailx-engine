import '../imports.dart';

const primaryColor = Color(0xff1b1340);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;

SidebarXController sidebarXController(bool extended) =>
    SidebarXController(selectedIndex: 0, extended: extended);

final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);

final divider = Divider(color: white.withOpacity(0.3), height: 1);

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({
    Key? key,
    required this.extended,
  }) : super(key: key);
  final bool extended;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return SidebarX(
        controller: sidebarXController(extended),
        theme: SidebarXTheme(
          decoration: const BoxDecoration(
            color: Color(0xff1b1340),
            // borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(color: Colors.white),
          selectedTextStyle: const TextStyle(color: Colors.white),
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xff1b1340),
            ),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actionColor.withOpacity(0.37),
            ),
            gradient: const LinearGradient(
              colors: [accentCanvasColor, canvasColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 30,
              )
            ],
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
        ),
        extendedTheme: const SidebarXTheme(
          width: 240,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Color(0xff1b1340),
          ),
          // margin: EdgeInsets.only(right: 10),
        ),
        showToggleButton: true,
        footerDivider: divider,
        headerBuilder: (context, extended) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: extended ? 46 : 0,
                    vertical: extended ? 20 : 0,
                  ),
                ),
              ),
              onPressed: siteController.toggleNewMsgDialog,
              child: extended
                  ? const Text(
                      "New Message",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.add,
                        size: 18,
                      ),
                    ),
            ),
          );
        },
        footerBuilder: (context, extended) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: extended ? 40 : 0,
                    vertical: extended ? 20 : 0,
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
              ),
              onPressed: () {
                showZeroNetxDialog(context);
              },
              child: extended
                  ? const Text(
                      "Switch Account",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                      ),
                    ),
            ),
          );
        },
        items: siteController.routes.map((element) {
          return SidebarXItem(
            label: extended ? element.label : null,
            icon: element.icon,
            onTap: element.onTap,
          );
        }).toList(),
      );
    });
  }
}
