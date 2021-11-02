import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'user.dart' as ud;

FirebaseService service = FirebaseService();

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen(
      {required this.uid, required this.contact, required this.convoID});
  final String uid, convoID;
  final ud.User contact;
  //final User contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            //need to write method to grab username based on uid. [search db for entry that matches uid. Then return name.]
            AppBar(automaticallyImplyLeading: true, title: Text(contact.name)),
        body: ChatScreen(uid: uid, convoID: convoID, contact: contact));
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {required this.uid, required this.convoID, required this.contact});
  final String uid, convoID;
  final ud.User contact;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String uid, convoID;
  late ud.User contact;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroller = ScrollController();

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    convoID = widget.convoID;
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: service
            .getCollection('conversations')
            .doc(convoID)
            .collection(convoID)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var listMessage = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) =>
                  buildItem(index, snapshot.data!.docs[index]),
              itemCount: snapshot.data!.docs.length,
              reverse: true,
              controller: _scroller,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildInput() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        autofocus: true,
                        maxLines: 5,
                        controller: _controller,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.send, size: 25),
                  onPressed: () => onSendMessage(_controller.text),
                ),
              ),
            ],
          ),
        ),
        width: double.infinity,
        height: 100.0);
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    //code that checks for read status
    if (!document['read'] && document['idTo'] == uid) {
      service.updateMessageRead(document, convoID);
    }

    if (document['idFrom'] == uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Bubble(
                  color: Colors.blueGrey,
                  elevation: 0,
                  padding: const BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Text(document['content'],
                      style: const TextStyle(color: Colors.white))),
              width: 200)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                child: Bubble(
                    color: Colors.white10,
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.leftTop,
                    child: Text(document['content'],
                        style: const TextStyle(color: Colors.white))),
                width: 200.0,
                margin: const EdgeInsets.only(left: 10.0),
              )
            ])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      _controller.clear();
      content = content.trim();
      service.sendMessage(convoID, uid, contact.id, content,
          DateTime.now().millisecondsSinceEpoch.toString());
      _scroller.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
