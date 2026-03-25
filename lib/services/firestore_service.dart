import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(User user) async {
    final userRef = _db.collection("users").doc(user.uid);

    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        "name": user.displayName,
        "email": user.email,
        "photo": user.photoURL,
        "uid": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}