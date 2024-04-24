import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';
import 'package:uni_course/models/comment_model.dart';
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

  //getter to get the comments collection from Firebase
  CollectionReference get _comments =>
      _fireStore.collection(FirebaseConstants.commentsCollection);

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

  //function to delete a post from fireBase
  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Upvotes a post and updates the Firestore document accordingly.
  /// If the user has previously downvoted the post, the user's ID will be removed from the 'downvotes' array
  /// and added to the 'upvotes' array. If the user has previously upvoted the post, the user's ID will be removed
  /// from the 'upvotes' array.

  void upvote(Post post, String userID) async {
    if (post.downvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userID]),
        'upvotes': FieldValue.arrayUnion([userID])
      });
    }
    if (post.upvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userID])
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userID])
      });
    }
  }

  /// Downvotes a post by removing the user's upvote and adding the user's downvote.
  ///
  /// If the user has already upvoted the post, their upvote is removed and their downvote is added.
  /// If the user has already downvoted the post, their downvote is removed.
  ///
  void downvote(Post post, String userID) async {
    if (post.upvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userID]),
        'downvotes': FieldValue.arrayUnion([userID])
      });
    }
    if (post.downvotes.contains(userID)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userID])
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userID])
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  /// Adds a comment to the Firestore database.
  ///
  /// The [comment] parameter represents the comment to be added.
  /// Returns a [FutureVoid] indicating the success or failure of the operation.
  /// Throws a [FirebaseException] if there is an error with the Firestore operation.
  /// Throws a [Failure] if there is an error that is not related to Firestore.
  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_posts
          .doc(_posts.id)
          .update({'commentCount': FieldValue.increment(1)}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> fetchComments(String postId) {
    return _comments.where('postId', isEqualTo: postId).snapshots().map(
        (event) => event.docs
            .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
