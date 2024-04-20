//this will talk to auth_repositiry from login Screen
//the point of this controller is to seperate auth logic from ui logic, for example if
//I want to show a snackBar when throwin an exception for an error in authintication, I won't
//do it in auth_repository but here instead.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/auth/repository/auth_repository.dart';
import 'package:uni_course/models/user_model.dart';

//provider to get access to the user data once he's signed in
//it's state is updated in the user.fold method down below
//used in homeScreen for now
final userProvider = StateProvider<UserModel?>((ref) => null);

//provider to access the AuthRepository class which has sign in methods and other shit (Refer to class)
//we ask for ref as a paremeter here because in sign_in_button we're having the sign in function outside of the Build function,
//therefore we must add a WidgetRef to make it accessible there
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) {
    return AuthController(
        authRepository: ref.watch(authRepositoryProvider), ref: ref);
  },
);

//provider that notifies about changes to the user's sign-in state (such as sign-in or sign-out).
//will be used in main.dart materilaApp routing
final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider
      .notifier); //we access the AuthController class itself using .notifier
  return authController.authStateChange;
});

//provider to return a stream of current user's data
final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

//
//class for calling all things authintication related, and setting up notifiers.
//
class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(
            false); //this will represent the loading, inititally it's false because the loading isn't happening

  //calls authStateChange in auth_repository
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  //call to AuthRepository getUserData getter
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void SignInWithGoogle(BuildContext context) async {
    state =
        true; //changed state of StateNotifier to true, to indicate 'loading' is now true
    final user = await _authRepository.signInWithGoogle();
    state = false; //inficates that 'loading' has finished.

    //for expection handling, we are using typeDef FutureEither to catch errors
    //l means faliure, r means success
    //Execute onLeft when value is [Left], otherwise execute onRight
    user.fold(
      (l) => showSnackBar(context, l.message),
      //r returns UserModel, state is the state of UserModel before we udpate it.
      (r) => _ref.read(userProvider.notifier).update((state) => r),
    );
  }

  void logout() async {
    _authRepository.logOut();
  }
}
