import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Utility to manually add missing users to Firestore
class FirestoreUserFix {
  static Future<void> ensureUserInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in');
      return;
    }

    // Check if user exists in Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      print('User not found in Firestore, adding...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': user.displayName ?? 'Unknown',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('User added to Firestore successfully');
    } else {
      print('User already exists in Firestore');
    }
  }
}
