import 'package:mdchatapp/home_builder.dart';

import 'firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
//import 'conversation_provider.dart';
import 'registration_page.dart';
import 'package:provider/provider.dart';

FirebaseService service = FirebaseService();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var UController = TextEditingController();
  var PController = TextEditingController();
  Route route = MaterialPageRoute(builder: (context) => ConversationView());
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    PController.dispose();
    UController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final fauth.User user = Provider.of<fauth.User>(context, listen: false);
    //final fauth.User user = Provider.of<fauth.User>(context);
    //fauth.User? user = service.auth.currentUser;
    //final User firebaseUser = Provider.of<User>(context);
    //fauth.User? currentUser;

    return Scaffold(
      body: Center(
          child: Center(
              //padding: EdgeInsets.fromLTRB(3.0, 20.0, 3.0, 0.0,),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            TextField(
              controller: UController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Email'),
            ),
            TextField(
                obscureText: true,
                controller: PController,
                decoration: const InputDecoration(
                    /*prefixText: 'prefix',*/
                    border: OutlineInputBorder(),
                    hintText: 'Password')),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                textStyle: const TextStyle(fontSize: 25),
              ),
              onPressed: () => {
                if (UController.text == "" || PController.text == "")
                  {
                    showDialog<String>(
                      //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                      //Otherwise send a popup that the login credentials were incorrect
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Login Status'),
                        content:
                            const Text('Please enter your login information.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              UController.clear();
                              PController.clear();
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    )
                  }
                else
                  {
                    service.emailSignInWithPassword(
                        UController.text, PController.text, context),
                    //sometimes need to press login twice
                    if (service.auth.currentUser != null)
                      {Navigator.pushReplacement(context, route)}
                    /*{
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ConversationView()))
                    }*/
                  }
              },
              child: const Text('Login'),
              //onPressed: () =>{attemptLogin()}
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                //textStyle: const TextStyle(Fontweight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationForm()),
                );
              },
              child: const Text('Create New Account'),
            ),
          ]))),
    );
  }
}
