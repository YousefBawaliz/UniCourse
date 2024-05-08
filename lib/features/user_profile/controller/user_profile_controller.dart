import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/enums/enums.dart';
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

  /// Retrieves a stream of posts belonging to a specific user.
  ///
  /// The [uid] parameter is the unique identifier of the user.
  /// Returns a [Stream] that emits a list of [Post] objects.
  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  /// Updates the karma of the current user.
  ///
  /// The [karma] parameter is the new [UserKarma] object representing the updated karma.
  /// Retrieves the current user from the [userProvider] and updates the karma value.
  /// Returns the result of the karma update operation as a [Future].
  /// If the update is successful, the user state is updated using the [userProvider.notifier].
  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }
}
