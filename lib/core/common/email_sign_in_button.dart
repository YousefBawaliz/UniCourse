import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/theme/pallete.dart';

class SignInButton2 extends ConsumerStatefulWidget {
  final String email;
  final String password;
  const SignInButton2({super.key, required this.email, required this.password});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInButton2State();
}

class _SignInButton2State extends ConsumerState<SignInButton2> {
  //this calls the AuthController SignInWithGoogle method, which in turn calls the
  //AuthRepository SignInWithGoogle method
  void signInWithEmailAndPassword(BuildContext context, WidgetRef ref) {
    print("email: ${widget.email}");
    print("password: ${widget.password}");
    ref
        .read(authControllerProvider.notifier)
        .login(widget.email, widget.password, context);
  }

  void navigateToLogInScreen(BuildContext context) {
    Routemaster.of(context).push('/');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ElevatedButton.icon(
        onPressed: () {
          signInWithEmailAndPassword(context, ref);
        },
        icon: Container(),
        label: const Text(
          "log in",
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
