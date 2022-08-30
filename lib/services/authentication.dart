import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
// FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<User?> login(String email, String password) async {
  try {
    User? user = (await auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print('Login Sucessful');
      return user;
    } else {
      print('login not succesful');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> register(String name, String email, String password) async {
  try {
    User? user = (await auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print('register Sucessful');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set({
        "name": name,
        "email": email,
        "status": "",
        "uid": auth.currentUser!.uid
      });
      return user;
    } else {
      print('register not succesful');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logout() async {
  try {
    auth.signOut();
  } catch (_) {}
  return null;
}
