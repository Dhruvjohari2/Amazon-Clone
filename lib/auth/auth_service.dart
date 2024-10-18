import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../cart/cart_provider.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;

  User? get user => _user;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      if (user != null) {
        print("hello $_user");
        await saveUserDataToFirestore(_user!, name);
      }

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;
      saveUserDataToFirestore(_user!, "");
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveUserDataToFirestore(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': name ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      Provider.of<CartProvider>(context, listen: false).clearCart();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
