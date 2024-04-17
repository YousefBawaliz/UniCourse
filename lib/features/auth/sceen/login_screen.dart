import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/sign_in_button.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';

class LogInScreen extends ConsumerWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //to render content conditionally based on sign in status
    final _isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Constants.logoPath,
          height: kToolbarHeight,
        ),
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
      body: _isLoading
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
              ],
            ),
    );
  }
}
