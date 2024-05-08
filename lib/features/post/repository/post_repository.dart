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

  //getter to get the savedPosts collection from Firebase
  final CollectionReference _savedPosts =
      FirebaseFirestore.instance.collection('savedPosts');

  //function to add a post to fireBase
  FutureVoid addPost(Post post) async {
    try {
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

  Stream<List<Post>> getPostsById(List<String> postId) {
    return _posts.where(FieldPath.documentId, whereIn: postId).snapshots().map(
        (event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
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
      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Fetches the comments for a given post ID.
  ///
  /// Returns a stream of lists of [Comment] objects.
  /// The stream emits a new list of comments whenever there is a change in the comments collection
  /// where the 'postId' field is equal to the provided [postId].
  /// Each comment is converted from a Firestore document snapshot to a [Comment] object using the [Comment.fromMap] method.
  Stream<List<Comment>> fetchComments(String postId) {
    return _comments.where('postId', isEqualTo: postId).snapshots().map(
        (event) => event.docs
            .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  /// Saves a post for a specific user.
  ///
  /// The [post] parameter represents the post to be saved.
  /// The [userID] parameter represents the ID of the user who is saving the post.
  ///
  /// Returns a [FutureVoid] that completes when the post is successfully saved.
  /// Throws a [FirebaseException] if there is an error while saving the post.
  /// Returns a [Failure] if there is an error that is not a [FirebaseException].
  // FutureVoid savePost(String userId, String postId) async {
  //   try {
  //     return right(_savedPosts.doc(userId).set({
  //       'userId': userId,
  //       'postId': postId,
  //     }));
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }

  ///todo: this is utterly stupid as it creates a new document for each saved post,
  ///edit it later to save the post ids in an array in the user document.
  Future<Either<Failure, String>> savePost(String userId, String postId) async {
    try {
      final querySnapshot = await _savedPosts
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // The post is not saved yet, so save it.
        await _savedPosts.add({
          'userId': userId,
          'postId': postId,
        });
        return right("Post saved successfully!");
      } else {
        // The post is already saved, so unsave it.
        await querySnapshot.docs.first.reference.delete();
        return right("Post unsaved");
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Fetches the saved posts for a given user.
  ///
  /// The [userId] parameter specifies the ID of the user whose saved posts are to be fetched.
  /// Returns a [Stream] of [List<String>] representing the IDs of the saved posts.
  Stream<List<String>> fetchSavedPosts(String userId) {
    return _savedPosts.where('userId', isEqualTo: userId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => doc['postId'] as String).toList());
  }
}
