import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gro_bak/view/widget/form_widget.dart';
import 'login.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _namaUsahaController =
      TextEditingController(); // Add controller for business name

  bool isSigningUp = false;
  String _role = "Pembeli";

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaUsahaController.dispose(); // Dispose controller for business name
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _role = "Pembeli";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _role == "Pembeli" ? Colors.blue : null,
                      ),
                      child: Text("Pembeli"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _role = "Penjual";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _role == "Penjual" ? Colors.blue : null,
                      ),
                      child: Text("Penjual"),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Username",
                  isPasswordField: false,
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                SizedBox(height: 10),
                if (_role == "Penjual")
                  FormContainerWidget(
                    controller: _namaUsahaController,
                    hintText: "Nama Usaha",
                    isPasswordField: false,
                  ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _signUp(
                      email: _emailController.text,
                      role: _role,
                      password: _passwordController.text,
                      namaUsaha: _namaUsahaController
                          .text, // Pass business name to signup function
                      username: _usernameController
                          .text, // Pass username to signup function
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isSigningUp
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp(
      {required String email,
      required String password,
      required String role,
      required String namaUsaha,
      required String username}) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = true;
      });
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String uid = _firebaseAuth.currentUser!.uid;
        await createMerchant(uid, namaUsaha);

        await createUser(email, role, username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        print('Error during sign up: $e');
        setState(() {
          isSigningUp = false;
        });
      }
    }
  }

  Future<void> createMerchant(String uid, String namaUsaha) async {
    DocumentReference merchantDocRef =
        FirebaseFirestore.instance.collection('merchant').doc(uid);
    await merchantDocRef.set({
      'nama_usaha': namaUsaha,
    });
  }

  Future<void> createUser(String email, String role, String username) async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    await userRef.doc(_firebaseAuth.currentUser!.uid).set({
      'nama': username,
      'email': email,
      'role': role,
      'phone_number': '',
      'latitude': '',
      'longitude': '',
      'timestamp': Timestamp.now(),
    });
  }
}
