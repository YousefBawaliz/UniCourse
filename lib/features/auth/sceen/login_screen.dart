import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/google_sign_in_button.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/auth/sceen/email_log_in_screen.dart';
import 'package:uni_course/features/auth/sceen/email_sign_up_screen.dart';
import 'package:uni_course/theme/pallete.dart';

class LogInScreen extends ConsumerWidget {
  const LogInScreen({super.key});

  void navigateToLogInScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SignInScreen(),
    ));
  }

  void navigateToSignUpScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SignUpScreen(),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //to render content conditionally based on sign in status
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title: Image.asset(
        //   Constants.logoPath,
        //   height: kToolbarHeight * 2,
        //   width: kToolbarHeight * 2,
        // ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Skip",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "dive into your courses!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    Constants.loginEmote,
                    height: 400,
                  ),
                ),
                const SignInButton(),
                // continue with email button,
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      navigateToLogInScreen(context);
                    },
                    icon: const Icon(Icons.email),
                    label: const Text(
                      "Continue with Email",
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
                ),
                TextButton(
                    onPressed: () {
                      navigateToSignUpScreen(context);
                    },
                    child: Text("Don't have an account? Sign up"))
              ],
            ),
    );
  }
}
