import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/home/delegates/search_community_delegate.dart';
import 'package:uni_course/features/home/drawers/community_list_drawer.dart';
import 'package:uni_course/features/home/drawers/profile_drawer.dart';
import 'package:uni_course/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  //change the tabViewPage
  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
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
      //index 0 is feed screen, index 1 is add screen
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      // bottomNavigationBar: NavigationBar(
      //   height: 70,
      //   destinations: const <Widget>[
      //     NavigationDestination(
      //       selectedIcon: Icon(Icons.home),
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //     ),
      //     NavigationDestination(
      //       icon: Badge(child: Icon(Icons.notifications_sharp)),
      //       label: 'Notifications',
      //     ),
      //     NavigationDestination(
      //       icon: Badge(
      //         child: Icon(Icons.add),
      //       ),
      //       label: 'add',
      //     ),
      //   ],
      // ),
      bottomNavigationBar: CupertinoTabBar(
        height: 70,
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
        ],
        onTap: onPageChange,
        currentIndex: _page,
      ),
    );
  }
}
