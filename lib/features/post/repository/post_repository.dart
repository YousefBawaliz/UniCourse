import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/models/post_model.dart';

//provider to be provided to post_controller
final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(fireStoreProvider));
});

//contains functions for posting, deleting posts, adding comments to posts
class PostRepository {
  final FirebaseFirestore _fireStore;
  PostRepository({required FirebaseFirestore firestore})
      : _fireStore = firestore;

  //getter to get the posts collection from Firebase
  CollectionReference get _posts =>
      _fireStore.collection(FirebaseConstants.postsCollection);

  //function to add a post to fireBase
  FutureVoid addPost(Post post) async {
    try {
      var communityDoc = await _posts.doc(post.id).get();
      //to ensure no 2 communities with the same name exist.
      if (communityDoc.exists) {
        throw 'community with the same name already exists';
      }
      //if no community with such name exists, set it
      //set return futureVoid, so does 'right'
      return right(
        //toMap because FireStore stores data as a map
        _posts.doc(post.id).set(
              post.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    //we're getting posts in communities where the community name matches the communities in the argument
    //sorted by date in descending order
    return _posts
        //where Creates and returns a new [Query] with additional filter on specified [field]. [field] refers to a field in a document.
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots() //get snapshots of the data
        .map(
          //map through the QuerySnapshots
          (event) => event
              .docs //Gets a list of all the documents included in this snapshot.
              .map(
                //map through the Documents from Snapshot
                //convert each document snapshot into a Post data model
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}
