import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lechat/models/user_model.dart';
import 'package:lechat/repositories/firebase_storage_repository.dart';
import 'package:lechat/screens/home_screen.dart';
import 'package:lechat/service/firebaseapi.dart';
import 'package:riverpod/riverpod.dart';

final authentication = Provider(
  (ref) => Authentication(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    ref: ref
  )
);

class Authentication {

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;


  Authentication({required this.auth, required this.firestore, required this.ref});
  
  
  User? getCurrentUser() {
    var user =  auth.currentUser;
    return user;
  }

  Future<Usuario> getUserById(String? uid) async {
    var userData = await firestore.collection('users').where('uid', isEqualTo: uid).get();
    var user = Usuario.fromObject(userData.docs.first);
    return user;
  }


  Future<List<Usuario>> getUsers(List<dynamic> userIds) async {
    List<Usuario> usersIn = [];

    await Future.forEach(userIds, (uid) async {
      QuerySnapshot userQuery = await firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (userQuery.docs.isNotEmpty) {
        usersIn.add(Usuario.fromObject(userQuery.docs.first));
      }
    });

    return usersIn;
  }

  Future<UserCredential> createUserWithEmailAndPassword({required String email,required String password}) async {    
    var newUser =  await auth.createUserWithEmailAndPassword(email: email, password: password);    
    return newUser;
  }

  void logout() async {
    await auth.signOut();
  }
  

  Future<UserCredential> signInWithEmailAndPassword({required String email,required String password}) async {
    var token = await FirebaseApi().getToken();
    log(token.toString());
    var userCredential =  await auth.signInWithEmailAndPassword(email: email, password: password);    
    await firestore.collection('users').doc(userCredential.user!.uid).update({'token' : token});
    return userCredential;
  }

  Future<void> updateprofile(String displayName, String? photoURL) async {
    try {
      var user = getCurrentUser();
      await user?.updateDisplayName(displayName);
      await user?.updatePhotoURL(photoURL);
    } catch (e) {
      rethrow;
    }
  }

  void saveUserData({
    required String name,
    required String? profilePic,
    required File? profileImage,
    required BuildContext context,
  }) async {
    String uid = auth.currentUser!.uid;
    try {
      if (profileImage != null) {      
        profilePic = await ref.read(firebaseStorageRepository).storeFileToFirebase('profilePic/$uid', profileImage);
      }
      await updateprofile(name,profilePic);
      var token = await FirebaseApi().getToken();
      var user = Usuario(name: name, uid: uid, profilePic: profilePic, token: token);
      await firestore.collection('users').doc(uid).set(user.toJson()).then(
        (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen(),), (route) => false)
      ); 
    } catch (e) {
      rethrow;
    }     
  }

  static String getErrorAuth(String code) {
    switch (code) {
      case "network-request-failed":
        return 'No internet to login!';
      case "invalid-email":
        return 'The email address is not valid!';
      case "email-already-in-use":
        return 'There already exists an account with the given email address';
      case "weak-password":
        return 'Password is not strong enough';
      case "user-not-found":
        return 'There is no user corresponding to the given email!';
      case "invalid-credential":
        return "The password is not valid!";
      default:
        return code;

    }
  }
}