// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signInAsAdmin(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final uid = result.user!.uid;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc['role'] == 'admin') {
        return null; // success
      } else {
        await _auth.signOut();
        return 'Access Denied: Not an admin';
      }
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }
}
