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
  TextEditingController _namaUsahaController = TextEditingController();
  TextEditingController _nomorTeleponController = TextEditingController();

  bool isSigningUp = false;
  String _role = "Pembeli";

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaUsahaController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Close the keyboard when the user taps outside a TextField
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 105),
                  Text(
                    'Daftar akun',
                    style: TextStyle(
                      fontSize: 42, // Equivalent to text-4xl in Tailwind CSS
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF060100),
                    ),
                  ),
                  SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Silahkan daftar sesuai dengan ',
                          style: TextStyle(
                            color: Colors
                                .grey, // Equivalent to text-zinc-500 in Tailwind CSS
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'kebutuhan!',
                          style: TextStyle(
                            color: Color(0xFF060100),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
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
                              _role == "Pembeli" ? Color(0xFFFEC901) : null,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Pembeli",
                          style: TextStyle(
                            color: _role == "Pembeli"
                                ? Color(0xFF060100)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _role = "Pedagang";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _role == "Pedagang" ? Color(0xFFFEC901) : null,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Pedagang",
                          style: TextStyle(
                            color: _role == "Pedagang"
                                ? Color(0xFF060100)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                  if (_role == "Pedagang") ...[
                    FormContainerWidget(
                      controller: _namaUsahaController,
                      hintText: "Nama Usaha",
                      isPasswordField: false,
                    ),
                    SizedBox(height: 10),
                    FormContainerWidget(
                      controller: _nomorTeleponController,
                      hintText: "Nomor Telepon",
                      isPasswordField: false,
                    ),
                    SizedBox(height: 10),
                  ],
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _signUp(
                        email: _emailController.text.isNotEmpty
                            ? _emailController.text
                            : null,
                        role: _role,
                        password: _passwordController.text.isNotEmpty
                            ? _passwordController.text
                            : null,
                        namaUsaha: _namaUsahaController.text.isNotEmpty
                            ? _namaUsahaController.text
                            : null,
                        username: _usernameController.text.isNotEmpty
                            ? _usernameController.text
                            : null,
                        nomorTelepon: _nomorTeleponController.text.isNotEmpty
                            ? _nomorTeleponController.text
                            : null,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color(0xFFFEC901),
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
                                    color: Color(0xFF060100),
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah memiliki akun?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFFEC901), // Yellow color for text
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(
                                    0.25, 0.25), // position of the shadow
                                blurRadius: 0.25, // blur effect
                                color: Color.fromARGB(
                                    128, 0, 0, 0), //ent black color
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp({
    required String? email,
    required String? password,
    required String role,
    required String? namaUsaha,
    required String? username,
    required String? nomorTelepon,
  }) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = true;
      });
      try {
        if (email == null || password == null || username == null) {
          throw Exception("Required fields are missing");
        }
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String uid = _firebaseAuth.currentUser!.uid;
        if (role == "Pedagang") {
          await createMerchant(uid, namaUsaha, nomorTelepon);
        }
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

  Future<void> createMerchant(
      String uid, String? namaUsaha, String? nomorTelepon) async {
    DocumentReference merchantDocRef =
        FirebaseFirestore.instance.collection('merchant').doc(uid);
    await merchantDocRef.set({
      'nama_usaha': namaUsaha ?? '',
      'nomor_telepon': nomorTelepon ?? '',
      'rute': [],
      'menu': [],
      'status': 'tutup',
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
