import '../imports.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: const Color(0xff1b1340),
      child: Row(
        children: const [
          SizedBox(
            // height: 100,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 70.0),
              child: Text(
                "ZeroMailX",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
