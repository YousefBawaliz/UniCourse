import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  void navigateToEditCommunityTools(BuildContext context) {
    Routemaster.of(context).push('//edit-community/$name');
  }

  void navigateToAddModsScreen(BuildContext context) {
    Routemaster.of(context).push('//add-mods/$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod tool"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text("add moderators"),
            onTap: () {
              navigateToAddModsScreen(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit community"),
            onTap: () {
              navigateToEditCommunityTools(context);
            },
          ),
        ],
      ),
    );
  }
}
