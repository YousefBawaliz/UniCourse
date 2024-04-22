//this class will have all the authentication methods of the app

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';
import 'package:uni_course/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) {
    return AuthRepository(
      firestore: ref.read(fireStoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider),
    );
  },
);

class AuthRepository {
  //since they are private we just initilize them here, we don't want them to be accessed outside of this class
  const AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;
  //firebase services needed for authentication
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  //a getter to get a [CollectionReference] for the specified Firestore path
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  //Notifies about changes to the user's sign-in state (such as sign-in or sign-out).
  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      //Holds fields describing a signed in user's identity,
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      //Retrieve [GoogleSignInAuthentication] for this account to use in credentials
      final googleAuth = await googleUser?.authentication;

      //credential for getting user details such as ID
      final credential = GoogleAuthProvider.credential(
        //The OAuth2 access token to access Google services.
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      //A UserCredential is returned from authentication requests such as [createUserWithEmailAndPassword].
      //signInWithCredential Asynchronously signs in to Firebase with the given 3rd-party credentials (e.g. a Google ID Token/Access)
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel userModel;

      //check if the user is a new user
      if (userCredential.additionalUserInfo!.isNewUser) {
        //we're gonna use this model to pass it into the fireStore database later on when the user signs up for the first time.
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [],
        );

        //we use the user uid as a unique identifier for the user document inside the users collection
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        //first: The first element of this stream, only returns a Future, hence why we use await
        //Stops listening to this stream after the first element has been received.
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(
          userModel); //right means success, according to FutureEither type definition
    } on FirebaseException catch (e) {
      throw e
          .message!; //throwing it to the next catch block, and then it will return left as a sign of failure
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //we're retrieving the Document related to the user, then we've mapped the snapshot to convert it into UserModel.
  //we need a stream and not a future here, so the user will not see the login screen again after refreshing the page for example,
  //sine there is a steady stream of userData that tells us there is a user signed in, and to see realtime updates happening
  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
