import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/theme/pallete.dart';

//we converted this into ConsumerWidget so we get access to ref and access the provider
class SignUpButton extends ConsumerWidget {
  final String email;
  final String password;
  final String userName;
  const SignUpButton(
      {super.key,
      required this.email,
      required this.password,
      required this.userName});

  //this calls the AuthController SignInWithGoogle method, which in turn calls the
  //AuthRepository SignInWithGoogle method
  void signUpWithEmailAndPassword(BuildContext context, WidgetRef ref) {
    ref
        .read(authControllerProvider.notifier)
        .signup(email, password, userName, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ElevatedButton.icon(
        onPressed: () {
          signUpWithEmailAndPassword(context, ref);
        },
        icon: Container(),
        label: const Text(
          "Sign up",
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
