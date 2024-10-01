import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketing_up/add_visit_screen.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/login_screen.dart';
import 'package:marketing_up/screens/login_screen_copy.dart';
import 'package:marketing_up/screens/add_employee_screen.dart';
import 'package:marketing_up/screens/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: prefs));
}

class MyApp extends StatelessWidget {

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SharedPreferences? sharedPreferences;

  MyApp({super.key, this.sharedPreferences});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) =>
            FirebaseProvider(firebaseFirestore: firebaseFirestore, firebaseAuth: firebaseAuth, preferences: sharedPreferences!)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(int.parse("0xFFE35335"))),
          useMaterial3: true,
        ),
        home: LoginScreenCopy(),
      ),
    );
  }

}
