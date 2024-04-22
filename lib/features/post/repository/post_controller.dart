import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/providers/storage_repository_provider.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/post/repository/post_repository.dart';
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

  //function to upload link post
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
}
