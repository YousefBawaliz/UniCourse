import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/theme/pallete.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToAddPostTypeScreen(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 120;
    double iconSize = 60;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Material(
      color: currentTheme.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "select post type",
            style: TextStyle(
              color: Color.fromARGB(206, 255, 255, 255),
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  onTap: () => navigateToAddPostTypeScreen(context, 'image'),
                  title: SizedBox(
                    height: cardHeightWidth,
                    width: cardHeightWidth,
                    child: Card(
                      color: currentTheme.colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: iconSize,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Image",
                            style: TextStyle(fontSize: 22),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () => navigateToAddPostTypeScreen(context, 'text'),
                  title: SizedBox(
                    height: cardHeightWidth,
                    width: cardHeightWidth,
                    child: Card(
                      color: currentTheme.colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.font_download,
                            size: iconSize,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "text",
                            style: TextStyle(fontSize: 22),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () => navigateToAddPostTypeScreen(context, 'link'),
                  title: SizedBox(
                    height: cardHeightWidth,
                    width: cardHeightWidth,
                    child: Card(
                      color: currentTheme.colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_outlined,
                            size: iconSize,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "link",
                            style: TextStyle(fontSize: 22),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () => navigateToAddPostTypeScreen(context, 'resource'),
                  title: SizedBox(
                    height: cardHeightWidth,
                    width: cardHeightWidth,
                    child: Card(
                      color: currentTheme.colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_copy_outlined,
                            size: iconSize,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "resource",
                            style: TextStyle(fontSize: 22),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
