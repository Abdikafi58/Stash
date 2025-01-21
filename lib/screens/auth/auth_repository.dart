import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Sign Up
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow; 
    }
  }

  
  Future<User?> logIn({required String email, required String password}) async {
    try {
      
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User account has been deleted.',
        );
      }

      return userCredential.user;
    } catch (e) {
      rethrow; 
    }
  }

  
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
