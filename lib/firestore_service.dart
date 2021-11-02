import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'convo.dart';
import 'user.dart' as ud;

//base authentication class for future projects

//any mention of 'User' from the tutorial code is ud.user

class FirebaseService {
  //add instances that allow use of each authentication method
  //create a method for each
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  static Map<String, UserEX> userMap = <String, UserEX>{};

  final StreamController<Map<String, UserEX>> _usersController =
      StreamController<Map<String, UserEX>>();

  FirebaseService() {
    _firestore.collection('users').snapshots().listen(_usersUpdated);
  }

  //method for performing simple currentUser login status
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<String?> getUserID() async {
    return auth.currentUser!.uid;
  }

  //gets name of any registered user
  Future<String> getName(User? user) async {
    String uid = user!.uid; //.toString();
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').where('UID', isEqualTo: uid).get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;
    //should only be one doc associated with each user's ID, so it is equal to checking a single item
    var checkDoc = docs[0].data() as Map<String, dynamic>;
    return checkDoc['Username'];
  }

  //method for returning current user's name
  Future<String?> getUsername() async {
    return auth.currentUser!.displayName;
  }

  //method for returning a given collection. Needed for adding new users to the db
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  Stream<Map<String, UserEX>> get users => _usersController.stream;

  void _usersUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    var users = _getUsersFromSnapshot(snapshot);
    _usersController.add(users);
  }

  Map<String, UserEX> _getUsersFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (var element in snapshot.docs) {
      UserEX user = UserEX.fromMap(element.id, element.data());
      userMap[user.id] = user;
    }

    return userMap;
  }

  //create account with email with password method
  Future<UserCredential> emailPassSignUp(String email, String password) async {
    //try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    /*} on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }*/
    return userCredential;
  }

  Future<void> emailSignInWithPassword(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  //email verification
  Future<void> verifyEmail() async {
    User? user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  //signout method
  Future<void> signOut() async {
    await auth.signOut();
  }

  //added methods from the tutorial's database.dart class to this one
  Stream<List<ud.User>> streamUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot snap) =>
                ud.User.fromMap(snap.data() as Map<String, dynamic>))
            .toList())
        .handleError((dynamic e) {
      //print(e);
    });
  }

  provideUsers() async {
    //const snapshot = await firebase.firestore().collection('events').get()
    //return snapshot.docs.map(doc => doc.data());
    var snap = await _firestore.collection('users').get();
    return snap.docs.map((doc) => doc.data());

    /*return _firestore
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot snap) =>
                ud.User.fromMap(snap.data() as Map<String, dynamic>))
            .toList())
        .handleError((dynamic e) {
      //print(e);
    });*/
  }

  //change Streams for Futures
  Stream<List<ud.User>> getUsersByList(List<String> userIds) {
    //Stream<List<ud.User>> getUsersByList(List<String> userIds)
    //creates list of size 500. Band-aid approach
    final List<Stream<ud.User>> streams = []..length = 500;
    // List();
    for (String id in userIds) {
      streams.add(_firestore.collection('users').doc(id).snapshots().map(
          (DocumentSnapshot snap) =>
              ud.User.fromMap(snap.data as Map<String, dynamic>)));
    }
    return StreamZip<ud.User>(streams).asBroadcastStream();
  }

  /*Future<List<ud.User>> makeUserList(List<String> userIds) {
    //makes an empty list of length 30
    final List<ud.User> userList = []..length = 30;
    for (String id in userIds)
    {

    }
  }*/

  /*Stream<List<Convo>> streamConversations(String uid) {
    return _firestore
        .collection('conversations')
        .orderBy('lastMessage.timestamp', descending: true)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot doc) => Convo.fromFireStore(doc))
            .toList());
  }*/

  void updateMessageRead(DocumentSnapshot doc, String convoID) {
    final DocumentReference documentReference = _firestore
        .collection('conversations')
        .doc(convoID)
        .collection(convoID)
        .doc(doc.id);

    documentReference
        .set(<String, dynamic>{'read': true}, SetOptions(merge: true));
  }

  void sendMessage(
    String convoID,
    String id,
    String pid,
    String content,
    String timestamp,
  ) {
    final DocumentReference convoDoc =
        _firestore.collection('conversations').doc(convoID);

    convoDoc.set(<String, dynamic>{
      'lastMessage': <String, dynamic>{
        'idFrom': id,
        'idTo': pid,
        'timestamp': timestamp,
        'content': content,
        'read': false
      },
      'users': <String>[id, pid]
    }).then((dynamic success) {
      final DocumentReference messageDoc = _firestore
          .collection('conversations')
          .doc(convoID)
          .collection(convoID)
          .doc(timestamp);

      //service._firestore.runTransaction((Transaction transaction) async {
      //await transaction.set(
      //messageDoc,
      messageDoc.update(<String, dynamic>{
        'idFrom': id,
        'idTo': pid,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'read': false
      }); //,
      //);
    });
  }
}

class UserEX {
  UserEX({
    required this.id,
    //required this.picture,
    required this.name,
  });

  factory UserEX.fromMap(String id, Map<String, dynamic> data) {
    return UserEX(id: id, /*picture: data['picture'],*/ name: data['Username']);
  }

  final String id;
  //final String? picture;
  final String name;
}
