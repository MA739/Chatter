import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mdchatapp/login_page.dart';
import 'package:mdchatapp/new_message_screen.dart';
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
  //navigate back to login page
  Route route = MaterialPageRoute(builder: (context) => LoginPage());
  late Stream<QuerySnapshot> fireStream;
  @override
  void initState() {
    super.initState();
    fireStream = service.getCollection('conversations').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final fauth.User? user = service.auth.currentUser;

    List<String> convoIDList = [];
    //returns user's name for top of screen
    String name = "User";
    void setName() {
      service.getName(user).then((String result) {
        setState(() {
          name = result;
        });
      });
    }

    //sets name variable to current user's name
    setName();

    String provideName() {
      return name;
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(children: <Widget>[
            Text(/*"Username"*/ provideName(),
                style: const TextStyle(fontSize: 18)),
            IconButton(
                onPressed: () => createNewConvo(context),
                icon: const Icon(Icons.add, size: 30)),
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
                          Navigator.pushReplacement(context, route)
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
              stream: fireStream, //get relevant collections/subcollection
              //if ConvoID contains userID, add it to the Stream. Logic is in other code,

              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                /*if there's no conversations to load, display  "Create a conversation with someone"
                else display current conversations*/
                if (snapshot.hasData) {
                  // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  getConvoIDList(convoIDList, documents);
                  return ListView(
                      //need to access subcollections

                      children: getList(convoIDList, user, documents));
                } else {
                  return const Text("Start a conversation with someone");
                }
              }),
        )));
  }

  /*iterates through list of conversation ids, checking if any of them contain the currrent
  user's ID. If it does, it searches through the DocSnapshot for that specific document and creates
  a Card with that Conversation's receiver as the title*/
  List<Widget> getList(
      List<String> cIDList, fauth.User? user, List<DocumentSnapshot> docs) {
    List<Widget> openConvos = [];
    for (String id in cIDList) {
      //compare if a conversation's id includes the current User. If so, create a card containing it's data for viewing
      if (id.contains(user!.uid)) {
        for (int i = 0; i < docs.length; i++) {
          var checkDoc = docs[i];
          if (checkDoc.id == id) {
            openConvos
                .add(Card(child: ListTile(title: Text(checkDoc['contact']))));
          }
        }

        //var docRef = service.getCollection('conversations').doc(id).get();

      }
    }
    return openConvos;
  }

  String getConvoID(String userID, String peerID) {
    return userID.hashCode <= peerID.hashCode
        ? userID + '_' + peerID
        : peerID + '_' + userID;
  }

  Future<void> getConvoIDList(
      List<String> list, List<DocumentSnapshot> result) async {
    //List<String> cIDList = [];
    //QuerySnapshot result = await service.getCollection('conversations').get();
    //final List<DocumentSnapshot> documents = result.docs;
    //List<String> docIDs = [];
    for (var doc in result) {
      list.add(doc.id);
    }
    /*for (String a in list) {
      print("CONVOID" + a);
    }*/
    //return cIDList;
  }

  //creates the screen that lists the users and
  //allows search functionality for initiating conversations
  void createNewConvo(BuildContext context) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NewMessageScreen()));
  }

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
