import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gro_bak/view/Pembeli.dart';
import 'package:gro_bak/view/register.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'firebase_options.dart';
import 'view/login.dart';
import 'view/Pedagang.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      // home: LoginPage(),
      // home: Pembeli(),
      home: BottomNavBar(selectedIndex: 2),
    );
  }
}
