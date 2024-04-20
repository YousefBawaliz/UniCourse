import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/storage_repository_provider.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/community/repository/community_repository.dart';
import 'package:uni_course/models/community_model.dart';

//provider to get access to the communties the user is part of
final userCommunitiesProvider = StreamProvider((ref) {
  return ref.watch(communityControllerProvider.notifier).getUserCommunities();
});

//provider to get access to a community
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

//provider for search function:
final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

//provider which gives access to this class
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) {
    final communityRepository = ref.watch(communityRepositoryProvider);
    final storageRepository = ref.watch(storageRepositoryProvider);
    return CommunityController(
        communityRepository: communityRepository,
        ref: ref,
        storageRepository: storageRepository);
  },
);

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  //we need that because we're gonna contact the user provider later to get the user id
  final Ref _ref;
  final StorageRepository _storageRepository;
  //
  //
  //
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  // we need context to show the snackBar later
  void createCommunity(String name, BuildContext context) async {
    state = true; ////loading indicator started
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        //initial members and mods are the person who created the community
        members: [uid],
        mods: [uid]);

    final res = await _communityRepository.createCommunity(community);
    state = false; //loading indicator is over
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Community created successfully');
        Routemaster.of(context).pop();
      },
    );
  }

  //call getUserCommunities from CommunityRepository
  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  //calls getCommunityByName from CommunityRepository
  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required File? profileFile,
      required File? bannerFile,
      required Community community,
      required BuildContext context}) async {
    state = true;
    if (profileFile != null) {
      // this will for example store the file in  communities/profile/communityName
      final res = await _storageRepository.storeFile(
          path: 'communities/profile', id: community.name, file: profileFile);

      res.fold(
          (l) => showSnackBar(context, l.message),
          //creating a new community model using copyWith function, because we can't reassign avater since it's final
          (r) => community = community.copyWith(avatar: r));
    }

    if (bannerFile != null) {
      // this will for example store the file in  communities/profile/communityName
      final res = await _storageRepository.storeFile(
          path: 'communities/banner', id: community.name, file: bannerFile);

      res.fold(
          (l) => showSnackBar(context, l.message),
          //creating a new community model using copyWith function, because we can't reassign avater since it's final
          (r) => community = community.copyWith(banner: r));
    }

    final res = await _communityRepository.editCommunity(community);

    state = false;
    //because we wanna go back from the edit community page after finishing saving the new data
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  //join/leave controller, pretty simple logic, if user id exists, leave, if he doesn't exist, join
  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider);
    Either<Failure, void> res;
    if (community.members.contains(user!.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (community.members.contains(user.uid)) {
          showSnackBar(context, 'Community left successfully!');
        } else {
          showSnackBar(context, 'Community joined successfully!');
        }
      },
    );
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }
}
