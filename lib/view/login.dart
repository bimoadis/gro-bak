import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gro_bak/view/pembeli/pages/page_switcher.dart';
import 'package:gro_bak/view/test_message_loc.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';
import 'package:gro_bak/view/widget/form_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pembeli/pages/Pembeli.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void validateInputs() {
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = "Please enter your email";
      } else if (!_emailController.text.contains('@')) {
        _emailError = "Please enter a valid email";
      } else {
        _emailError = null;
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = "Please enter your password";
      } else if (_passwordController.text.length < 6) {
        _passwordError = "Password must be at least 6 characters";
      } else {
        _passwordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.21),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Hallo,',
                      //   style: TextStyle(
                      //     fontSize:
                      //         42, // Equivalent to text-4xl in Tailwind CSS
                      //     fontWeight: FontWeight.bold,
                      //     color: Color(0xFF060100),
                      //   ),
                      // ),
                      const SizedBox(
                        height: 8,
                      ), // Adding some space between the Text widgets
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Selamat datang di ',
                              style: TextStyle(
                                fontSize:
                                    42, // Equivalent to text-3xl in Tailwind CSS
                                fontWeight: FontWeight.bold,
                                color: Color(
                                    0xFF060100), // Default color for the rest of the text
                              ),
                            ),
                            TextSpan(
                              text: 'Gro-bak!',
                              style: TextStyle(
                                fontSize:
                                    42, // Equivalent to text-3xl in Tailwind CSS
                                fontWeight: FontWeight.bold,
                                color: Color(
                                    0xFFFEC901), // Yellow color for "Gro-bak!"
                                shadows: [
                                  Shadow(
                                    offset: Offset(
                                        1.0, 1.0), // position of the shadow
                                    blurRadius: 1.5, // blur effect
                                    color: Color.fromARGB(128, 0, 0,
                                        0), // semi-transparent black color
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.02), // Adding some space before the paragraph
                      const Text(
                        'Silahkan masukkan email dan password akun anda',
                        style: TextStyle(
                          color: Colors
                              .grey, // Equivalent to text-zinc-500 in Tailwind CSS
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormContainerWidget(
                      controller: _emailController,
                      hintText: "Email",
                      isPasswordField: false,
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _emailError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormContainerWidget(
                      controller: _passwordController,
                      hintText: "Password",
                      isPasswordField: true,
                    ),
                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _passwordError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    validateInputs();
                    if (_emailError == null && _passwordError == null) {
                      setState(() {
                        _isSigning = true;
                      });
                      signIn(_emailController.text, _passwordController.text);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFFFEC901),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isSigning
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFF060100),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum memiliki akun?",
                        style: TextStyle(
                          color: Color(0xFF060100),
                        )),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFFFEC901),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              offset:
                                  Offset(0.25, 0.25), // position of the shadow
                              blurRadius: 0.25, // blur effect
                              color: Color.fromARGB(
                                  128, 0, 0, 0), // semi-transparent black color
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void route() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in.');
      return;
    }

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (documentSnapshot.exists) {
        String role = documentSnapshot.get('role');
        print('User role: $role');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);

        if (role == "Pedagang") {
          print('Navigating to BottomNavBar');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(),
            ),
          );
        } else if (role == "Pembeli") {
          print('Navigating to Pembeli');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PageSwitcherPembeli(),
            ),
          );
        } else {
          print('Unknown role: $role');
          setState(() {
            _isSigning = false;
          });
        }
      } else {
        print('Document does not exist on the database');
        setState(() {
          _isSigning = false;
        });
      }
    } catch (e) {
      print('Exception in route: $e');
      setState(() {
        _isSigning = false;
      });
    }
  }

  void signIn(String email, String password) async {
    setState(() {
      _isSigning = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan status login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', userCredential.user!.uid);

      route();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isSigning = false;
        if (e.code == 'invalid-credential') {
          _emailError = 'Please check your email.';
          _passwordError = 'Please check your password.';
        } else {
          _emailError = 'An error occurred. Please try again.';
          _passwordError = 'An error occurred. Please try again.';
        }
      });
      print('FirebaseAuthException code: ${e.code}');
      print('FirebaseAuthException message: ${e.message}');
    } catch (e) {
      setState(() {
        _isSigning = false;
        _emailError = 'An unknown error occurred. Please try again.';
        _passwordError = 'An unknown error occurred. Please try again.';
      });
      print('Exception: $e');
    }
  }
}
