import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/features/post/screens/add_reply_screen.dart';
import 'package:uni_course/models/comment_model.dart';

class CommentCardR extends ConsumerStatefulWidget {
  final Comment comment;
  const CommentCardR({
    super.key,
    required this.comment,
  });

  @override
  _CommentCardRState createState() => _CommentCardRState();
}

class _CommentCardRState extends ConsumerState<CommentCardR> {
  void deleteComment(BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .deleteComment(widget.comment, context);
  }

  void navigateToReplyScreen(BuildContext context) {
    // Routemaster.of(context).push('/AddReplyScreen/${widget.comment}');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddReplyScreen(comment: widget.comment),
    ));
  }

  void addReply() {
    ref.read(postControllerProvider.notifier).addReply(
          text: "",
          context: context,
          comment: widget.comment,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.comment.profilePic,
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'u/${widget.comment.username}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.comment.text)
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  ref.watch(userProvider)!.name == widget.comment.username
                      ? IconButton(
                          onPressed: () {
                            deleteComment(context);
                          },
                          icon: const Icon(Icons.delete),
                        )
                      : const SizedBox(),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
