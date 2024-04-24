import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
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
}
