//we're gonna have 2 main routes: logged in route, logged out route

import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/features/community/screens/community_screen.dart';
import 'package:uni_course/features/community/screens/create_community_screen.dart';
import 'package:uni_course/features/community/screens/edit_community_screen.dart';
import 'package:uni_course/features/community/screens/mod_tools_screen.dart';
import 'package:uni_course/features/home/screens/home_screen.dart';
import 'package:uni_course/features/auth/sceen/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LogInScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/create-community': (route) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) =>
      MaterialPage(child: CommunityScreen(name: route.pathParameters['name']!)),
  '/mod-tools/:name': (route) =>
      MaterialPage(child: ModToolsScreen(name: route.pathParameters['name']!)),
  '/edit-community/:name': (route) => MaterialPage(
      child: EditCommunityScreen(name: route.pathParameters['name']!)),
});
