import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/storage_repository_provider.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/post/repository/post_repository.dart';
import 'package:uni_course/models/comment_model.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/models/post_model.dart';
import 'package:uuid/uuid.dart';
import 'package:uni_course/core/utils.dart';

//provider to get access to AddPostRepository functions
final postControllerProvider = StateNotifierProvider<PostController, bool>(
  (ref) {
    final postRepository = ref.watch(postRepositoryProvider);
    final storageRepository = ref.watch(storageRepositoryProvider);
    return PostController(
        postRepository: postRepository,
        ref: ref,
        storageRepository: storageRepository);
  },
);

//provider to fetch post feed
final userPostProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

//provider to get a post by it's Id, to be used when fetching comments of a post
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

//provider to get post comments
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchComments(postId);
});

//provider to get saved posts
final getSavedPostsProvider = StreamProvider.family((ref, String userId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchSavedPosts(userId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //function to upload text posts to FireStore
  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    //state true means loading has started
    state = true;
    //creates a unique id for the post using the UUID package
    String postid = Uuid().v1();
    final user = _ref.read(userProvider)!;
    //instantiate a post object to be uploaded
    final Post post = Post(
      id: postid,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );
    //calls addPost from _postRepository
    final res = await _postRepository.addPost(post);
    //stops loading
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      //for success, display a message and pop back to a root screen
      showSnackBar(context, 'posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  //function to upload post of type link
  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);

    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  //upload post of type image
  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    //an Either to check if image was posted or not (refer to storeFile function)
    final imageRes = await _storageRepository.storeFile(
      //store image in FireBase storage to /posts/community
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        //r is the link of the image stored in FireBase storage
        link: r,
      );

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    //return an empty stream if no posts are present yet
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    state = true;
    final res = await _postRepository.deletePost(post);
    state = false;
    res.fold(
      (l) => null,
      (r) => showSnackBar(context, "post deleted successfully!"),
    );
  }

  /// Upvotes a post.
  ///
  /// This method takes a [post] object and upvotes it by the current user.
  /// It retrieves the current user from the [_ref] using the [userProvider].
  /// The upvote operation is performed by calling [_postRepository.upvote]
  /// with the [post] and the user's unique identifier ([user.uid]).
  void upvote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRepository.upvote(post, user.uid);
  }

  void downvote(Post post) async {
    final user = _ref.read(userProvider)!;
    _postRepository.downvote(post, user.uid);
  }

  //get a post by it's Id
  //to be used when fetching comments of a post
  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  /// Adds a comment to a post.
  ///
  /// It retrieves the current user from the [userProvider] and uses it to create a new comment object.
  /// The comment is then added to the post using the [_postRepository.addComment] method.
  /// If the comment is added successfully, no action is taken.
  /// If an error occurs, a snackbar with the error message is shown using the [showSnackBar] method.
  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.addComment(
      Comment(
        id: const Uuid().v1(),
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.profilePic,
      ),
    );
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  /// Fetches the comments for a given post.
  ///
  /// Returns a stream of lists of [Comment] objects.
  Stream<List<Comment>> fetchComments(String postId) {
    return _postRepository.fetchComments(postId);
  }

  void savePost({
    required BuildContext context,
    required String postId,
  }) async {
    final userId = _ref.read(userProvider)!.uid;
    final res = await _postRepository.savePost(userId, postId);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, r));
  }

  Stream<List<String>> fetchSavedPosts(String userId) {
    return _postRepository.fetchSavedPosts(userId);
  }
}
