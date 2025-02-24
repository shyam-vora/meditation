import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meditation/core/constant/firebase_constants.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/main_tabview/main_tabview_screen.dart';

class AuthRepository {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  Future<UserModel> signInWithGoogle(bool isFromLogin) async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential;

    if (isFromLogin) {
      userCredential = await auth.signInWithCredential(credential);
    } else {
      userCredential = await auth.currentUser!.linkWithCredential(credential);
    }

    UserModel userModel;

    if (userCredential.additionalUserInfo!.isNewUser) {
      userModel = UserModel(
        name: userCredential.user!.displayName ?? "No Name ",
        email: userCredential.user!.email ?? "No Email",
        uid: userCredential.user!.uid,
      );
      await users.doc(userCredential.user!.uid).set(userModel.toMap());
    } else {
      userModel = await getUserData(userCredential.user!.uid);
    }

    return userModel;
  }

  Future<void> signupUser(String email, String password, String username, BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': username,
          'email': email,
          'uid': userCredential.user!.uid,
        });
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainTabViewScreen()));
    } catch (e) {
      print('Error signing up: $e');
    }
  }

  Future<void> signinUser(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
       
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('You are Logged in')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password did not match')));
      }
    }
  }

  Future<UserModel> getUserData(String uid) async {
    DocumentSnapshot docSnapshot = await users.doc(uid).get();
    if (docSnapshot.exists) {
      return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      throw Exception("User data not found.");
    }
  }

  CollectionReference users =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);
}
