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
    //use this after string list is shown to work. Will need to change getUSERIDList method
    //final Map<String, String> userMap = {};

    TextEditingController search = TextEditingController();
    late Stream<QuerySnapshot> users;
    users = service.getCollection('users').snapshots();

    /*Future<void> geUserList(
      List<String> list, List<DocumentSnapshot> result) async {
    //List<String> cIDList = [];
    //QuerySnapshot result = await service.getCollection('conversations').get();
    //final List<DocumentSnapshot> documents = result.docs;
    //List<String> docIDs = [];
    for (var doc in result) {
      list.add(doc.id);
    }*/

    //method to fetch users from firestore
    //get snapshot of the collection. Then convert to map so I can iterate and get specific subdata
    /*void getUserList() {
      users = service
          .getCollection('users')
          .get;
      
      /*  //.then((QuerySnapshot querySnapshot) 
          {
        ///for each user, add their name to a list...
        for (int i = 0; i < querySnapshot.size; i++){
          var checkDoc = querySnapshot;
        }
        
        for (var s in querySnapshot.docs) {
          userDirectory.add(s);
        }
      });*/
    }*/

    //getUserIDList(userDirectoryList, user);
    getUserIDMap(userDirectoryMap, user);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(children: const <Widget>[
            Text("Search Users", style: TextStyle(fontSize: 18)),
            //need to create way for user to input text
            /*IconButton(
                onPressed: () => createNewConvo(context),
                icon: const Icon(Icons.add, size: 30)),*/
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
    final List<String> userIDList = [];
    //final List<String> userNameList = [];
    //add userIDS from map to userIDList
    for (var key in userMap.keys) {
      userIDList.add(key);
    }

    /*for (var value in userMap.values)
    {
      userNameList.add(value);
    }*/

    //populates list with usernames of contacts. For map, must ensure that current user's ID is not included
    for (String contact in userIDList) {
      if (contact != service.getUserID().toString()) {
        //need to iterate through userMap and get the correct key/username by comparison
        list.add(UserRow(
            uid: service.getUserID().toString(),
            contactName: contact,
            contactID: userMap['contact'] as String));
        list.add(Divider(thickness: 1.0));
      }
    }
    return list;
  }
}

class UserRow extends StatelessWidget {
  const UserRow(
      {required this.uid, required this.contactName, required this.contactID});
  final String uid;
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
    String convoID = getConvoID(uid, contactID);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => NewConversationScreen(
            uid: uid,
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
