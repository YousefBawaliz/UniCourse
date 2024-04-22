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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen(context, 'image'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: currentTheme.colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen(context, 'text'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: currentTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  Icons.font_download,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen(context, 'link'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: currentTheme.colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                child: Icon(
                  Icons.link_outlined,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
