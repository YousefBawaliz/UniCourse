import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/core/common/post_card.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/theme/pallete.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postID;
  const CommentScreen({super.key, required this.postID});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: ref.watch(getPostByIdProvider(widget.postID)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                        fillColor: currentTheme.drawerTheme.backgroundColor,
                        hintText: 'Add a Comment',
                        filled: true,
                        border: InputBorder.none),
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Text(error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}
