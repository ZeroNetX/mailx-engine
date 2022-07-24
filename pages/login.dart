import '../imports.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          const Text(
            "Welcome to",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "ZeroMailX",
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text("END-TO-END ENCRYPTED P2P MESSAGING SYSTEM"),
          const Spacer(flex: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Please login to continue",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ZeroNet.instance.connect(admin, override: true);
              final msg = await ZeroNet.instance.certListFuture();
              await ZeroNet.instance.certSetFuture('zeroid.bit');
              // showDialog(context: context, builder: (context) {
              //   return const LoginDialog();
              // });
            },
            child: const Text('Login'),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
