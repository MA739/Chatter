import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'new_convo_screen.dart';
import 'user.dart' as ud;

FirebaseService service = FirebaseService();

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);
  @override
  NewMessageScreenState createState() => NewMessageScreenState();
}

class NewMessageScreenState extends State<NewMessageScreen> {
  @override
  Widget build(BuildContext context) {
    final fauth.User? user = service.auth.currentUser;
    //need to get collection from user directory... minus the current user
    //final List<ud.User> userDirectory = [];
    //final List<String> userDirectory = [];
    final Map<String, String> userDirectoryMap = {};
    //final Map<String, String> userMap = {};

    TextEditingController search = TextEditingController();
    late Stream<QuerySnapshot> users;
    users = service.getCollection('users').snapshots();

    //getUserIDList(userDirectoryList, user);
    getUserIDMap(userDirectoryMap, user);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Row(children: const <Widget>[
            Text("Search Users", style: TextStyle(fontSize: 18)),
          ]),
          //actions: <Widget>[],
        ),
        body: SafeArea(
            child: Center(
          child: StreamBuilder(
              stream: users, //get relevant collections/subcollection
              //if ConvoID contains userID, add it to the Stream. Logic is in other code,

              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                /*if there's no conversations to load, display  "Create a conversation with someone"
                else display current conversations*/
                if (snapshot.hasData) {
                  //getListViewItems(userDirectory, user);
                  getListViewItems(userDirectoryMap, user);

                  // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                      shrinkWrap: true,
                      children: getListViewItems(userDirectoryMap, user));
                } else {
                  //return full user list, scrollabble
                  return const Text("UserList");
                }
              }),
        )));
  }

  List<Widget> getListViewItems(Map<String, String> userMap, fauth.User? user) {
    //List<Widget> getListViewItems(List<String> userDirectory, fauth.User? user) {
    final List<Widget> list = <Widget>[];
    //stores names, actually
    final List<String> userNameList = [];
    //add userIDS from map to userNameList
    for (var key in userMap.keys) {
      userNameList.add(key);
      //expected keys: DU, | HH64, | GT,
      //vals should be their respective userIDs
      /*print("userMap Key: " + key);
      String val = userMap[key] as String;
      print("Usermap Val: " + val);*/
    }

    /*for (var value in userMap.values)
    {
      userNameList.add(value);
    }*/

    //populates list with usernames of contacts. For map, must ensure that current user's ID is not included
    for (String contactName in userNameList) {
      if (contactName != service.getUserID().toString()) {
        //need to iterate through userMap and get the correct key/username by comparison
        //gets corresponding userid from map and casts it as a string
        String cID = userMap[contactName] as String;
        list.add(UserRow(
            currentUseruid: service.auth.currentUser!.uid,
            contactName: contactName,
            contactID: cID));
        list.add(Divider(thickness: 1.0));
      }
    }
    return list;
  }
}

class UserRow extends StatelessWidget {
  const UserRow(
      {required this.currentUseruid,
      required this.contactName,
      required this.contactID});
  final String currentUseruid;
  final String contactName;
  final String contactID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => createConversation(context, contactID, contactName),
      child: Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(10.0),
          child: Center(
              child: Text(contactName,
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)))),
    );
  }

  void createConversation(
      BuildContext context, String contactID, String contactName) {
    String convoID = getConvoID(currentUseruid, contactID);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => NewConversationScreen(
            uid: currentUseruid,
            contactName: contactName,
            contactID: contactID,
            convoID: convoID)));
  }
}

String getConvoID(String userID, String peerID) {
  return userID.hashCode <= peerID.hashCode
      ? userID + '_' + peerID
      : peerID + '_' + userID;
}

//populates userDirectory list
Future<void> getUserIDMap(Map<String, String> map, fauth.User? user) async {
//Future<void> getUserIDList(List<String> list, fauth.User? user) async {
  //, List<DocumentSnapshot> result) async {

  //List<String> cIDList = [];
  QuerySnapshot result = await service.getCollection('users').get();
  final List<DocumentSnapshot> documents = result.docs;
  //List<String> docIDs = [];
  for (var doc in documents) {
    if (doc.id != user!.uid) {
      map[doc['Username']] = doc['UID'];
      //creates entry username, id
      //list.add(doc['UID']);
    }
  }
  /*for (String a in list) {
      print("CONVOID" + a);
    }*/
  //return cIDList;
}
