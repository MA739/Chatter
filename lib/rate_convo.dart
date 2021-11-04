import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;

FirebaseService service = FirebaseService();

class votePage extends StatefulWidget {
  const votePage({required this.userID});
  //profilePage({Key? key}) : super(key: key);
  final String userID;

  @override
  _votePageState createState() => new _votePageState();
}

class _votePageState extends State<votePage> {
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
      body: Center(
          child: Center(
              //padding: EdgeInsets.fromLTRB(3.0, 20.0, 3.0, 0.0,),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            TextField(
              controller: UController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Rate User"),
            ),

}