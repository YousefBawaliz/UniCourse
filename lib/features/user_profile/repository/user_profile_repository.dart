import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
import 'package:uni_course/core/enums/enums.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';
import 'package:uni_course/models/post_model.dart';
import 'package:uni_course/models/user_model.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserRepository(firebaseFirestore: ref.watch(fireStoreProvider));
});

class UserRepository {
  final FirebaseFirestore _firebaseFirestore;
  UserRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //to display posts on user profile
  //get posts where user uid is equal to the uid of the post
  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => Post.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  /// Updates the karma of a user in the Firestore database.
  ///
  /// Takes a [UserModel] object as input and updates the 'karma' field in the
  /// Firestore document corresponding to the user's UID.
  ///
  /// Returns a [FutureVoid] that completes when the update operation is finished.
  /// If the update is successful, the [FutureVoid] resolves to `null`. If an
  /// error occurs during the update, the [FutureVoid] throws a [FirebaseException]
  /// with the error message. If an unexpected error occurs, the [FutureVoid] returns
  /// a [Failure] object containing the error message.
  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({'karma': user.karma}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
