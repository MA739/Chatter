import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderInit());
}

FirebaseService service = FirebaseService();
//stores user images
//FirebaseStorage storage = FirebaseStorage.instance;

/*class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProviderInit(),
    );
  }
}*/

class ProviderInit extends StatelessWidget {
  const ProviderInit({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return /*StreamProvider<fauth.User?>.value(
        value: service.auth.authStateChanges(),
        initialData: service.auth.currentUser, //as Stream<fauth.User>?,
        child:*/
        const MaterialApp(
            title: 'Chat App',
            debugShowCheckedModeBanner: false,
            home: Home() //LoginPage(),
            );
    //);
  }
}
