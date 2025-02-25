import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meditation/core/constant/firebase_constants.dart';
import 'package:meditation/models/user_model.dart';

final googleSignIn = GoogleSignIn();

class AuthRepository {
  final auth = FirebaseAuth.instance;

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

  Future<String?> signupUser(String email, String password, String username,
      BuildContext context) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': username,
          'email': email,
          'uid': userCredential.user!.uid,
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted. \n Please use valid email address.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signinUser(String email, String password) async {
    try {
      final UserCredential creds = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      log(creds.toString(), name: "creds");
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user Found with this Email';
      } else if (e.code == 'wrong-password') {
        return 'Password did not match';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted. \n Please use valid email address.';
      } else if (e.code == "invalid-credential") {
        return "Email or Password is incorrect";
      } else {
        log(e.toString());
        return e.message;
      }
    } catch (e) {
      return e.toString();
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
