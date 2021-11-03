import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firestore_service.dart';
import 'new_message_screen.dart';
import 'user.dart' as ud;
//import 'package:firebase_auth/firebase_auth.dart';

FirebaseService service = FirebaseService();

class NewMessageProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return /*StreamProvider<List<ud.User>>.value(
      value: service.streamUsers(),
      initialData: [],
      child: NewMessageScreen(),
    );*/
        NewMessageScreen();
  }
}
