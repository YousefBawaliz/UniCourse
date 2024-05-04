import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/theme/pallete.dart';

class ProfileDrawer extends ConsumerStatefulWidget {
  const ProfileDrawer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends ConsumerState<ProfileDrawer> {
  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void navigateToSavedPosts(BuildContext context) {
    Routemaster.of(context).push('/u/savedPosts');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  Future<void> waitOneSecond() async {
    await Future.delayed(const Duration(seconds: 1));
    // Code to be executed after 1 second delay
    print('One second has passed!');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            const SizedBox(height: 10),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              title: const Text('My Profile'),
              leading: const Icon(Icons.person),
              onTap: () {
                navigateToUserProfile(context, user.uid);
              }
              // navigateToUserProfile(context, user.uid)
              ,
            ),
            // const SizedBox(height: 10),
            ListTile(
              title: const Text('Saved posts'),
              leading: const Icon(Icons.person),
              onTap: () {
                navigateToSavedPosts(context);
              }
              // navigateToUserProfile(context, user.uid)
              ,
            ),
            const Divider(),

            ListTile(
              title: const Text('Log Out'),
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () => logOut(ref),
            ),
            Switch.adaptive(
              value: ref.watch(themeNotifierProvider.notifier).mode ==
                  ThemeMode.dark,
              //todo: switch isn't changing.
              onChanged: (value) {
                setState(() {
                  toggleTheme(ref);
                });

                ref.watch(themeNotifierProvider.notifier).mode;
              },
            ),
          ],
        ),
      ),
    );
  }
}
