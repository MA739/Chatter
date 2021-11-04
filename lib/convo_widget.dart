import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user.dart' as ud;
import 'new_convo_screen.dart';
import 'home_builder.dart';

class ConvoListItem extends StatelessWidget {
  ConvoListItem(
      {Key? key,
      required this.userID,
      required this.peerID,
      required this.peerName,
      required this.lastMessage})
      : super(key: key);
  final String userID, peerID, peerName;

  //final fauth.User user;
  //final ud.User peer;
  Map<dynamic, dynamic> lastMessage;

  late BuildContext context;
  late String groupId;
  late bool read;

  @override
  Widget build(BuildContext context) {
    if (lastMessage['idFrom'] == userID) {
      read = true;
    } else {
      read = lastMessage['read'] == null ? true : lastMessage['read'];
    }
    this.context = context;
    groupId = getGroupChatId();

    return Container(
        margin: const EdgeInsets.only(
            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              buildContent(context),
            ])));
  }

  Widget buildContent(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        //clear
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => NewConversationScreen(
                uid: userID,
                contactName: peerName,
                contactID: peerID,
                convoID: getGroupChatId())));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child:
                        //shows peerID as conversation identifier. Shows that each chat is distinct
                        buildConvoDetails(peerID, context)),
                //this one pushes peerName, which I am struggling to give
                //buildConvoDetails(peerName, context)),
              ],
            ),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }

  Widget buildConvoDetails(String title, BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              read
                  ? Container()
                  : Icon(Icons.brightness_1,
                      color: Theme.of(context).accentColor, size: 15)
            ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text(lastMessage['content'],
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.clip),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                getTime(lastMessage['timestamp']),
                textAlign: TextAlign.right,
              ),
            )
          ],
        )
      ],
    );
  }

  String getTime(String timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    DateFormat format;
    if (dateTime.difference(DateTime.now()).inMilliseconds <= 86400000) {
      format = DateFormat('jm');
    } else {
      format = DateFormat.yMd('en_US');
    }
    return format
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }

  String getGroupChatId() {
    if (userID.hashCode <= peerID.hashCode) {
      return userID + '_' + peerID;
    } else {
      return peerID + '_' + userID;
    }
  }
}
