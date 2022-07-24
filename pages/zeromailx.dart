import '../imports.dart';

class ZeroMailX extends StatelessWidget {
  const ZeroMailX({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ZeroMailX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        body: Obx(
          () {
            var isUserLoggedIn = siteController.isUserLoggedIn.value;
            return Column(
              children: [
                if (isUserLoggedIn) const HeaderWidget(),
                Expanded(
                  child: !isUserLoggedIn ? const LoginPage() : const HomePage(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
