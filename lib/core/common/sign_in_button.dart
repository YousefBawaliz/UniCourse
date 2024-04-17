import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/theme/pallete.dart';

//we converted this into ConsumerWidget so we get access to ref and access the provider
class SignInButton extends ConsumerWidget {
  const SignInButton({super.key});

  //this calls the AuthController SignInWithGoogle method, which in turn calls the
  //AuthRepository SignInWithGoogle method
  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).SignInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ElevatedButton.icon(
        onPressed: () {
          return signInWithGoogle(context, ref);
        },
        icon: Image.asset(
          Constants.google,
          width: 35,
        ),
        label: const Text(
          "Continue with google",
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
