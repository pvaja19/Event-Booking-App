import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:event_booking/views/user/HomePage.dart';
import 'package:event_booking/views/user/LoginPage.dart';

class UserController extends GetxController {
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user without uploading image to Firebase Storage
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    File? profileImage, // Kept for UI, not uploaded
  }) async {
    try {
      isLoading.value = true;

      // Step 1: Register user with Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Save user data in Firestore (no image upload)
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': '', // Empty or default placeholder
        'createdAt': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
      Get.offAll(() => const LoginPage());
    } catch (e) {
      isLoading.value = false;

      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        Get.snackbar("Email Already Registered",
            "Please use a different email or log in.");
      } else {
        Get.snackbar("Registration Error", e.toString());
      }
    }
  }

  // Login user
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
      Get.offAll(() => const HomePage());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Login Failed", e.toString());
    }
  }
}
