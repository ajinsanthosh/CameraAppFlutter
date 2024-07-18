import 'package:camera/Sreen1.dart';
import 'package:camera/db_camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initialisaDatabase();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'demo',
      theme: ThemeData(
        primaryColor: Colors.blue
      ),
      home: const Sreen1(),
    );
  }
}