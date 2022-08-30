import 'dart:developer';

import 'package:firebase_flutter_practise/login_page.dart';
import 'package:firebase_flutter_practise/services/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  final _passwordController = TextEditingController();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Firebase-Register'),
      ),
      body: isloading
          ? Center(
              child: Container(
                child: const CircularProgressIndicator(color: Colors.red),
              ),
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
                          return 'Please enter your name';
                        }
                        return null;
                      }),
                      controller: _nameController,
                      onTap: () {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter your name',
                          labelText: 'Name',
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
                            register(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim())
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  isloading = false;
                                });

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()));
                                log('register successful');
                              } else {
                                log('register not success');
                              }
                            });
                          }
                        },
                        child: const Text('Register')),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: [
                          //*************** */
                          const TextSpan(text: 'Already have an account? '),
                          //*********** */
                          TextSpan(
                              text: 'Login',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // goes to sign up page.
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                                })
                        ],
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  // Future register() async {
  //   try {
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim());
  //   } catch (e) {
  //     FirebaseAuthException(code: 'e');
  //   }
  // }
}
