import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/home/delegates/search_community_delegate.dart';
import 'package:uni_course/features/home/drawers/community_list_drawer.dart';
import 'package:uni_course/features/home/drawers/profile_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Scaffold(
      appBar: AppBar(
        //we used builder here so that the context matches the context the drawer is in
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              displayDrawer(context);
            },
            icon: const Icon(Icons.menu),
          );
        }),
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              //pre built function that Shows a full screen search page and returns the search result selected by the user when the page is closed.
              showSearch(
                  context: context,
                  delegate: SearchCommunityDelegate(ref: ref));
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () {
                displayEndDrawer(context);
              },
            );
          }),
        ],
      ),
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
    );
  }
}
