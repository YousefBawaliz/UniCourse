// the goal of this file is to create a provider for firebase services we're gonna use,
//like auth,storage,firestore, google sign in, such that they won't be instantiated everytime
//we rebuild the application, and they stay as global varibales.

//these will be used in AuthRepository provider, which will be used  in auth_controller provider respectively

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final fireStoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final authProvider = Provider((ref) {
  return FirebaseAuth.instance;
});

final storageProvider = Provider((ref) {
  return FirebaseStorage.instance;
});

final googleSignInProvider = Provider((ref) {
  return GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
});
