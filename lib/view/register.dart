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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaUsahaController = TextEditingController();
  // final TextEditingController _nomorTeleponController = TextEditingController();

  bool isSigningUp = false;
  String _role = "Pembeli";

  @override
  void dispose() {
    _usernameController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _namaUsahaController.dispose();
    // _nomorTeleponController.dispose();
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
                  const SizedBox(height: 105),
                  const Text(
                    'Daftar akun',
                    style: TextStyle(
                      fontSize: 42, // Equivalent to text-4xl in Tailwind CSS
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF060100),
                    ),
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: const TextSpan(
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
                  const SizedBox(height: 8),
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
                          backgroundColor: _role == "Pembeli"
                              ? const Color(0xFFFEC901)
                              : null,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Pembeli",
                          style: TextStyle(
                            color: _role == "Pembeli"
                                ? const Color(0xFF060100)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _role = "Pedagang";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _role == "Pedagang"
                              ? const Color(0xFFFEC901)
                              : null,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Pedagang",
                          style: TextStyle(
                            color: _role == "Pedagang"
                                ? const Color(0xFF060100)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FormContainerWidget(
                    controller: _usernameController,
                    hintText: "Username",
                    isPasswordField: false,
                  ),
                  const SizedBox(height: 10),
                  FormContainerWidget(
                    controller: _numberController,
                    hintText: "Number",
                    isPasswordField: false,
                  ),
                  const SizedBox(height: 10),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 10),
                  if (_role == "Pedagang") ...[
                    FormContainerWidget(
                      controller: _namaUsahaController,
                      hintText: "Nama Usaha",
                      isPasswordField: false,
                    ),
                    const SizedBox(height: 10),
                    // FormContainerWidget(
                    //   controller: _nomorTeleponController,
                    //   hintText: "Nomor Telepon",
                    //   isPasswordField: false,
                    // ),
                    // const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _signUp(
                        number: _numberController.text.isNotEmpty
                            ? _numberController.text
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
                        // nomorTelepon: _nomorTeleponController.text.isNotEmpty
                        //     ? _nomorTeleponController.text
                        //     : null,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEC901),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isSigningUp
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Color(0xFF060100),
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah memiliki akun?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp({
    required String? number,
    required String? password,
    required String role,
    required String? namaUsaha,
    required String? username,
    // required String? nomorTelepon,
  }) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = true;
      });
      try {
        if (number == null || password == null || username == null) {
          throw Exception("Required fields are missing");
        }
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: '${formatPhoneNumber(number)}@number.com',
          password: password,
        );
        String uid = _firebaseAuth.currentUser!.uid;
        if (role == "Pedagang") {
          await createMerchant(uid, namaUsaha);
        }
        await createUser(number, role, username);
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

  Future<void> createMerchant(String uid, String? namaUsaha) async {
    DocumentReference merchantDocRef =
        FirebaseFirestore.instance.collection('merchant').doc(uid);
    await merchantDocRef.set({
      'nama_usaha': namaUsaha ?? '',
      'rute': [],
      'menu': [],
      'status': 'tutup',
    });
  }

  Future<void> createUser(String number, String role, String username) async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    await userRef.doc(_firebaseAuth.currentUser!.uid).set({
      'nama': username,
      'role': role,
      'phone_number': formatPhoneNumber(number),
      'latitude': '',
      'longitude': '',
      'timestamp': Timestamp.now(),
      'profileImage':
          'https://firebasestorage.googleapis.com/v0/b/gro-bak.appspot.com/o/swappy-20240626_075440.png?alt=media&token=bdd1ff21-ce3b-4aa5-a53b-a9d66605610e',
    });
  }
}

String formatPhoneNumber(String number) {
  String input = number;
  if (input.startsWith('0')) {
    String formatted = '62${input.substring(1)}';
    print(formatted);
    return formatted;
  } else {
    print(input);
    return input;
  }
}
