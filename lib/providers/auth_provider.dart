import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utem_foodie/services/user_services.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String error = '';
  final UserServices _userServices = UserServices();
  DocumentSnapshot? snapshot;

  Future<DocumentSnapshot?> getUserDetails() async {
    if (_auth.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((value) {
        snapshot = value;
      });
    }
  }

  Future<UserCredential?> signInWithEmail(
      {String? email,
      String? password,
      String? number,
      String? firstName,
      String? lastName}) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
    } on FirebaseAuthException catch (e) {
      error = e.code;
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      error = e.toString();
    }
    return userCredential;
  }

  Future<UserCredential?> signIn(String email, String password) async {
    UserCredential? result;

    try {
      result = await checkUserThenLogin(email, password);
    } catch (e) {
      error = e.toString();
    }

    return result;
  }

  Future<UserCredential?> checkUserThenLogin(
      String email, String password) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        try {
          return await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
        } catch (e) {
          error = e.toString();
        }
      } else {
        error = 'Looks like you are not a customer!';
      }
    });
  }

  createUser(
      {String? id,
      String? number,
      String? email,
      String? firstName,
      String? lastName}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'defaultDeliveryLocation': '',
    });
  }
}
