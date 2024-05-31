import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gro_bak/view/Pembeli.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';

class LoginLogic {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // late Function(int) _onItemTapped; // Fungsi callback
  // final int _selectedIndex; // Indeks yang dipilih

  // LoginLogic(this._selectedIndex, this._onItemTapped); // Konstruktor

  // Future<void> signIn(
  //     BuildContext context, String email, String password) async {
  //   try {
  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     _route(context);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     }
  //   }
  // }

  // void _route(BuildContext context) {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   var kk = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user!.uid)
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       if (documentSnapshot.get('role') == "Pedagang") {
  //         // Navigasi ke BottomNavBar dengan fungsi callback
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => BottomNavBar(
  //                 // selectedIndex: _selectedIndex, // Set indeks yang sesuai
  //                 // onItemTapped: _onItemTapped, // Set fungsi callback
  //                 ),
  //           ),
  //         );
  //       } else {
  //         // Navigasi ke Pembeli
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => Pembeli(),
  //           ),
  //         );
  //       }
  //     } else {
  //       print('Document does not exist on the database');
  //     }
  //   });
  // }
}
