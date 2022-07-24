import '../imports.dart';

import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart' as web
    if (dart.library.io) 'package:sembast/sembast_io.dart';

String dbPath = 'store.db';

Future<Database> getDatabase() async {
  if (kIsWeb) {
    final dbFactory = web.databaseFactoryWeb;
    return await dbFactory.openDatabase(dbPath);
  } else {
    final dbFactory = databaseFactoryIo;
    return await dbFactory.openDatabase(dbPath);
  }
}
