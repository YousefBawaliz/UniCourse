import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/providers/storage_repository_provider.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/user_profile/repository/user_profile_repository.dart';
import 'package:uni_course/models/post_model.dart';
import 'package:uni_course/models/user_model.dart';

//provider to access user_profile methods
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

//provider to get access to user posts to display them in user profile screen
final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required UserRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  /// Edits the user profile with the provided parameters.
  ///
  /// - `profileFile`: The file representing the user's profile picture. Can be `null` if no changes are made.
  /// - `bannerFile`: The file representing the user's banner image. Can be `null` if no changes are made.
  /// - `context`: The build context used to show the snackbar and navigate back.
  /// - `name`: The new name for the user.
  ///
  /// This method updates the user's profile by uploading the profile picture and banner image (if provided),
  /// and then updates the user's name. Finally, it calls the `editProfile` method of the `_userProfileRepository`
  /// to save the changes to the backend. If any error occurs during the process, a snackbar is shown with the error message.
  /// If the changes are saved successfully, the user provider is updated and the user is navigated back to the previous screen.

  void editUser({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );
      res.fold(
        //r is the download url
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }
}
