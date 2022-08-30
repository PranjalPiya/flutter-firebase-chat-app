import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_practise/chatt_app_page.dart';
import 'package:firebase_flutter_practise/login_page.dart';
import 'package:firebase_flutter_practise/services/authentication.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

//To check the current state of the app, we have to use WidgetsBinindObserver
class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isloading = false;
  var currentUser = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void callChatDetailScreen(BuildContext context, String name, String uid) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatDetail(friendUid: uid, friendName: name)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  void setStatus(String status) async {
    // TODO: implement setState
    await _firestore.collection('users').doc(auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('hi - ${auth.currentUser!.email}'),
        actions: [
          IconButton(
              onPressed: () {
                logout().then((value) {
                  if (value == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginPage()));
                  } else {
                    return null;
                  }
                });
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('uid', isNotEqualTo: currentUser)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: const [
                  Text('Something is wrong'),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                // Map<String, dynamic>? data = document.data()!;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        callChatDetailScreen(
                            context, document['name'], document['uid']);
                        log('this is uid ${document['uid']}');
                        // callChatScreen(document['name'], document['uid']);
                      },
                      // {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => ChatDetail(
                      //             friendUid: auth.currentUser!.uid,
                      //             friendName: document['name'])));
                      // String roomId = chatRoomId(
                      //     auth.currentUser!.displayName!, document['name']);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => ChatRoom(
                      //       chatRoomId: roomId,
                      //       userMap: document[0],
                      //     ),
                      //   ),
                      // );
                      //   log('Tapped');
                      // },
                      child: ListTile(
                          title: Text(document['name']),
                          leading: const Icon(Icons.person),
                          subtitle: Text(document['email']),
                          trailing: const Icon(Icons.chat_bubble)),
                    ),
                  ],
                );
              }).toList(),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
