import '../imports.dart';

const primaryColor = Color(0xff1b1340);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;

final sidebarXController = SidebarXController(selectedIndex: 0, extended: true);
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);

final divider = Divider(color: white.withOpacity(0.3), height: 1);

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: sidebarXController,
      theme: SidebarXTheme(
        // margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xff1b1340),
          // borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(color: Colors.white),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          border: Border.all(color: const Color(0xff1b1340)),
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
        decoration: BoxDecoration(
          color: Color(0xff1b1340),
        ),
        // margin: EdgeInsets.only(right: 10),
      ),
      showToggleButton: false,
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return Container(
          margin: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: extended
                ? ButtonStyle(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                  )
                : null,
            onPressed: () {},
            child: extended
                ? const Text(
                    "New Message",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add),
          ),
        );
      },
      items: siteController.routes.map((element) {
        return SidebarXItem(
          label: element.label,
          icon: element.icon,
          onTap: element.onTap,
        );
      }).toList(),
    );
  }
}
