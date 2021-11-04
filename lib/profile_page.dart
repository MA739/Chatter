import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;

FirebaseService service = FirebaseService();

class profilePage extends StatefulWidget {
  const profilePage({required this.userID});
  //profilePage({Key? key}) : super(key: key);
  final String userID;

  @override
  _profilePageState createState() => new _profilePageState();
}

class _profilePageState extends State<profilePage> {
//var docID = this.widget.docId;
  //fauth.User? user = service.auth.currentUser;
  late String ID;
  List<Widget> stats = [];
  @override
  void initState() {
    super.initState();
    ID = widget.userID;
    /*convoStream = service
        .getCollection('conversations')
        .doc(convoID)
        .collection(convoID)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text('UserProfile. Excuse the nak')),
        body: SafeArea(
            child: Center(
          child: StreamBuilder(
              stream: service
                  .getCollection('users')
                  .snapshots() //fireStream
                  .distinct(), //get relevant collections/subcollection
              //if ConvoID contains userID, add it to the Stream. Logic is in other code,

              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                /*if there's no conversations to load, display  "Create a conversation with someone"
                else display current conversations*/
                if (snapshot.hasData) {
                  //Snapshot.docs for fireStream, which holds Conversation Info
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                      //need to access subcollections

                      children: displayProfile(ID, documents));
                } else {
                  return const Text("Placeholder Profile");
                }
              }),
        )));
  }

  List<Widget> displayProfile(String userID, List<DocumentSnapshot> documents) {
    //QuerySnapshot result = await service.getCollection('users').get();
    //final List<DocumentSnapshot> documents = results.docs;
    //List<String> docIDs = [];
    for (var doc in documents) {
      if (doc.id == userID) {
        int total = doc['ConvoRank'];
        int voteCount = doc['VoteCount'];
        var result;
        if (total < 0) {
          result = "Unrated";
        } else {
          result = total / voteCount;
        }
        stats.add(Card(
            child: ListTile(
                title: Text("Username"), subtitle: Text(doc['Username']))));
        stats.add(Card(
            child: ListTile(
                title: Text("Average Score"), subtitle: Text(result))));
        //adduNameList[0] = doc['Username'];
        //creates entry username, id
        //list.add(doc['UID']);
      }
      //FORMAT
      //Card(child: ListTile(title: Text(checkDoc['users'][1]))));

    }
    return stats;
  }
}
