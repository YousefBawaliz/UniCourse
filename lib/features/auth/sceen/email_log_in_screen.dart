import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/email_sign_in_button.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      setState(() {
        email = _emailController.text;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
  }

  // EMAIL LOGIN
  // Future<void> loginWithEmail({
  //   required String email,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     print(email);
  //     print(password);
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message!); // Displaying the error message
  //   }
  // }

  void signInWithEmailAndPassword(BuildContext context, WidgetRef ref,
      String email, String password, String userName) {
    ref.read(authControllerProvider.notifier).login(email, password, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16.0),
            SignInButton2(
                email: _emailController.text,
                password: _passwordController.text)

            // TextButton(
            //   onPressed: () {
            //     loginWithEmail(
            //       email: _emailController.text,
            //       password: _passwordController.text,
            //       context: context,
            //     );
            //   },
            //   child: const Text('Log In'),
            // )
          ],
        ),
      ),
    );
  }
}
