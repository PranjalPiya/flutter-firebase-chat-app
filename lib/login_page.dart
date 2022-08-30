import 'dart:developer';

import 'package:firebase_flutter_practise/home_page.dart';
import 'package:firebase_flutter_practise/register_page.dart';
import 'package:firebase_flutter_practise/services/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isloading = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Firebase-Login'),
      ),
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      }),
                      controller: _emailController,
                      onTap: () {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter your email',
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          setState(() {
                            isloading = false;
                          });
                          return 'Please enter your Password';
                        }
                        return null;
                      }),
                      controller: _passwordController,
                      onTap: () {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              isloading = true;
                            });
                            login(_emailController.text.trim(),
                                    _passwordController.text.trim())
                                .then((user) {
                              if (user != null) {
                                setState(() {
                                  isloading = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Homepage()));
                                log('login success');
                              } else {
                                log('login fail');
                              }
                            });
                          }
                        },
                        child: const Text('Login')),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: [
                          //*************** */
                          const TextSpan(text: 'Don\'t have an account? '),
                          //*********** */
                          TextSpan(
                              text: 'Sign up',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // goes to sign up page.
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                                })
                        ],
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

// //We created a dynamic future method for login.
//   Future login() async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim());
//     } catch (e) {
//       FirebaseAuthException(code: 'e');
//     }
//   }
}
