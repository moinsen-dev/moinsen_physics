import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moinsen_physics/_index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MoinsenPhysicsApp(),
    ),
  );
}
