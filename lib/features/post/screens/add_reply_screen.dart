import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/post/widgets/comment_card_reduced.dart';
import 'package:uni_course/features/post/widgets/expanded_post_card.dart';
import 'package:uni_course/features/post/widgets/post_card.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/features/post/widgets/comment_card.dart';
import 'package:uni_course/features/post/widgets/reply_card.dart';
import 'package:uni_course/models/comment_model.dart';
import 'package:uni_course/models/post_model.dart';
import 'package:uni_course/theme/pallete.dart';

class AddReplyScreen extends ConsumerStatefulWidget {
  final Comment comment;
  const AddReplyScreen({super.key, required this.comment});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddReplyScreenState();
}

class _AddReplyScreenState extends ConsumerState<AddReplyScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addReply(Comment comment) {
    ref.read(postControllerProvider.notifier).addReply(
          context: context,
          comment: comment,
          text: commentController.text,
        );
    setState(() {
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          CommentCardR(comment: widget.comment),
          ref.watch(getRepliesProvider(widget.comment.id)).when(
                data: (data) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ReplyCard(reply: data[index]);
                      },
                    ),
                  );
                },
                loading: () => const Loader(),
                error: (error, _) => Text(error.toString()),
              ),
          TextField(
            onSubmitted: (value) => addReply(widget.comment),
            controller: commentController,
            decoration: InputDecoration(
              fillColor: Colors.grey[900],
              hintText: 'Add a reply',
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.circular(5.0), // Slightly rounded border
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
