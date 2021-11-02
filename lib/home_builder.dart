import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'convo_widget.dart';
import 'firestore_service.dart';
//import 'message_provider.dart';
import 'convo.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'user.dart' as u;

FirebaseService service = FirebaseService();

//equivalent to homebuilder in guide
class ConversationView extends StatefulWidget {
  const ConversationView({Key? key}) : super(key: key);
  @override
  _ConversationViewState createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  //<ConversationView> {
  //String userName = "fillerName";
  //update userName value before widget is built

  @override
  Widget build(BuildContext context) {
    final fauth.User? user = service.auth.currentUser;
    //returns user's name for top of screen

    String provideName() {
      String name = "User";
      service.getName(user).then((String result) {
        setState(() {
          name = result;
        });
      });
      return name;
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(children: <Widget>[
            Text(/*"Username"*/ provideName(),
                style: const TextStyle(fontSize: 18)),
            /*IconButton(
                onPressed: () => createNewConvo(context),
                icon: const Icon(Icons.add, size: 30)),*/
          ]),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(primary: Colors.white),
              //logout action here. Well... pop up asking if they want to log out. On ok press, logout and return to login screen
              onPressed: () {
                showDialog<String>(
                  //confirm user signout
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        //This is where it would navigate to the actual app's content
                        onPressed: () => {
                          service.auth.signOut(),
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst)
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Log Out"),
            ),
          ],
        ),
        body: SafeArea(
            child: Center(
          child: StreamBuilder(
              stream: service
                  .getCollection('conversations')
                  .snapshots(), //get relevant collections/subcollection
              //if ConvoID == userID_peerID, add it to the Stream. Logic is in other code,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                /*if (snapshot.hasData) {
                  // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                      //need to access subcollections
                      children: documents
                          .map((doc) => Card(
                                child: ListTile(
                                    title: Text(doc['MessageContent']),
                                    //replace with peerName
                                    subtitle: Text((doc['Date Time Posted']
                                        .toDate()
                                        .toString()))),
                                //replace with preview of lastMessage. For placeholder, just show text
                              ))
                          .toList());
                } else {*/
                return const Text("Start a conversation with someone");
                //}
              }),
        )));
  }

  //if there's no conversations to load, display  "Create a conversation with someone"
  //else display current conversations

  /*void createNewConvo(BuildContext context) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NewMessageProvider()));
  }*/

  Map<String, u.User> getUserMap(List<u.User> users) {
    final Map<String, u.User> userMap = {};
    for (u.User a in users) {
      userMap[a.id] = a;
    }
    return userMap;
  }

  //List<String> getUserIds(List<Convo> _convos, fauth.User user) {
  /*List<String> getUserIds(List<Convo> _convos) {
    final List<String> users = <String>[];
    //List<Convo> convoList = <Convo>[];
    if (_convos != null) {
      for (Convo c in _convos) {
        c.userIds[0] != user.uid
            ? users.add(c.userIds[0])
            : users.add(c.userIds[1]);
      }
    }
    return users;
  }*/

}
