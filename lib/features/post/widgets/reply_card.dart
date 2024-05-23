import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/features/post/screens/add_reply_screen.dart';
import 'package:uni_course/models/reply_model.dart';

class ReplyCard extends ConsumerStatefulWidget {
  final Reply reply;
  const ReplyCard({
    Key? key,
    required this.reply,
  }) : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends ConsumerState<ReplyCard> {
  // void deleteReply(BuildContext context) {
  //   ref
  //       .read(postControllerProvider.notifier)
  //       .deleteReply(widget.reply, context);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 34,
        right: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.reply.profilePic,
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
                        'u/${widget.reply.username}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.reply.text)
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  ref.watch(userProvider)!.name == widget.reply.username
                      ? IconButton(
                          onPressed: () {},
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
