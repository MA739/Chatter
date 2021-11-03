import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'new_convo_screen.dart';
import 'user.dart' as ud;

FirebaseService service = FirebaseService();

class NewMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fauth.User? user = service.auth.currentUser;
    //need to get collection from user directory... minus the current user
    final List<ud.User> userDirectory = [];
    var users;
    //method to fetch users from firestore
    //get snapshot of the collection. Then convert to map so I can iterate and get specific subdata
    void getUserList() {
      users = service
          .getCollection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        //for each user, add their name to a list...
        for (ud.User s in users) {
          userDirectory.add(s);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Select Contact')),
      body: userDirectory != null
          ? ListView(
              shrinkWrap: true, children: getListViewItems(userDirectory, user))
          : Container(),
    );
  }

  List<Widget> getListViewItems(List<ud.User> userDirectory, fauth.User? user) {
    final List<Widget> list = <Widget>[];
    for (ud.User contact in userDirectory) {
      if (contact.id != service.getUserID().toString()) {
        list.add(
            UserRow(uid: service.getUserID().toString(), contact: contact));
        list.add(Divider(thickness: 1.0));
      }
    }
    return list;
  }
}

class UserRow extends StatelessWidget {
  const UserRow({required this.uid, required this.contact});
  final String uid;
  final ud.User contact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => createConversation(context),
      child: Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(10.0),
          child: Center(
              child: Text(contact.name,
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)))),
    );
  }

  void createConversation(BuildContext context) {
    String convoID = getConvoID(uid, contact.id);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => NewConversationScreen(
            uid: uid, contact: contact, convoID: convoID)));
  }
}

String getConvoID(String userID, String peerID) {
  return userID.hashCode <= peerID.hashCode
      ? userID + '_' + peerID
      : peerID + '_' + userID;
}
