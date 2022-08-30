import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetail extends StatefulWidget {
  final friendUid;
  final friendName;

  const ChatDetail({Key? key, this.friendUid, this.friendName})
      : super(key: key);

  @override
  _ChatDetailState createState() => _ChatDetailState(friendUid, friendName);
}

class _ChatDetailState extends State<ChatDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final friendUid;
  final friendName;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  var chatDocId;
  final _textController = TextEditingController();

  _ChatDetailState(this.friendUid, this.friendName);
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    await chats
        // .collection('chats')
        .where('users', isEqualTo: {friendUid: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });

              log("this is charDocId:- $chatDocId");
            } else {
              await chats.add({
                'users': {currentUserId: null, friendUid: null},
                'names': {
                  currentUserId: FirebaseAuth.instance.currentUser?.displayName,
                  friendUid: friendName
                }
              }).then((value) => {chatDocId = value});
            }
          },
        )
        .catchError((error) {});
  }

  void sendMessage(String msg) {
    if (msg == '') return;
    chats.doc(chatDocId).collection('messages').add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentUserId,
      'friendName': friendName,
      'msg': msg
    }).then((value) {
      _textController.text = '';
    });
  }

  bool isSender(String friend) {
    return friend == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(friendUid).snapshots(),
          builder: ((context, snapshot) {
            log("this is the friend UId -; $friendUid");
            log("this is myUid ${_auth.currentUser!.uid}");
            return Container(
              child: Column(
                children: [
                  Text(friendName),
                  Text(
                    snapshot.data!['status'],
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            );
          }),
        ),
        // Text(friendName),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            )),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.phone))],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chats
                  .doc(chatDocId)
                  .collection('messages')
                  .orderBy('createdOn', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }

                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return Center(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: const [
                //         CircularProgressIndicator(),
                //         SizedBox(
                //           width: 20,
                //         ),
                //         Text(
                //           "Loading...!",
                //           style: TextStyle(fontSize: 18),
                //         ),
                //       ],
                //     ),
                //   );
                // }

                if (snapshot.hasData) {
                  Object data;
                  return SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (() {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }),
                            child: ListView(
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              children: snapshot.data!.docs.map(
                                (DocumentSnapshot document) {
                                  var data = document.data()!;
                                  log(document.toString());
                                  log(document['msg']);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Wrap(
                                        alignment:
                                            isSender(document['uid'].toString())
                                                ? WrapAlignment.end
                                                : WrapAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            // padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: isSender(
                                                      document['uid']
                                                          .toString())
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Card(
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  color: isSender(
                                                          document['uid']
                                                              .toString())
                                                      ? Colors.green.shade100
                                                      : Colors.blue.shade100,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 40,
                                                        vertical: 8),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment: isSender(
                                                              document['uid']
                                                                  .toString())
                                                          ? CrossAxisAlignment
                                                              .end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          document['msg'],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 17),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.003,
                                                ),
                                                Padding(
                                                  padding: isSender(
                                                          document['uid']
                                                              .toString())
                                                      ? const EdgeInsets.only(
                                                          right: 5)
                                                      : const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    document['createdOn'] ==
                                                            null
                                                        ? DateTime.now()
                                                            .toString()
                                                        : document['createdOn']
                                                            .toDate()
                                                            .toString(),

                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: isSender(
                                                                document['uid']
                                                                    .toString())
                                                            ? Colors.grey
                                                            : Colors.grey),
                                                    // DateTime.now("${message.time}");
                                                    // DateFormat('hh:mm a')
                                                    //     .format(message.time),
                                                    // style: Theme.of(context).textTheme.caption,

                                                    // style: TextStyle(
                                                    //   fontSize: 12,
                                                    //   color: Colors.grey.shade500,
                                                    // ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20,
                                  offset: Offset.zero,
                                  spreadRadius: 2,
                                  color: Colors.grey,
                                )
                              ],
                              color: Colors.grey.shade200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30))),
                                    controller: _textController,
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: const Icon(
                                    Icons.send_sharp,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      sendMessage(_textController.text))
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
