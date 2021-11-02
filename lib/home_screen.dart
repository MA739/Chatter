import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
//import 'conversation_provider.dart';

//not really needed, atm
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    //final User firebaseUser = Provider.of<User>(context);
    //return const LoginPage();

    /*return (firebaseUser != null)
        ? ConversationProvider(user: firebaseUser)
        //loginpage needs to return the fauth.user type somehow
        : const LoginPage();*/
    //login first... then load conversationProvider
    return const LoginPage();
  }
}
