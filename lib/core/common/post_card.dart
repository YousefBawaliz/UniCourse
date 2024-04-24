import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/models/post_model.dart';
import 'package:uni_course/theme/pallete.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  //buildContext is needed to diaply snackbar
  void deletePost(BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(widget.post, context);
  }

  void upvotePost() async {
    ref.read(postControllerProvider.notifier).upvote(widget.post);
  }

  void downvotePost() async {
    ref.read(postControllerProvider.notifier).downvote(widget.post);
  }

  //navigate to the user profile page of the user who posted the post
  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${widget.post.uid}');
  }

  //navigate to the community page of the community the post was posted in
  void navigatetoCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${widget.post.communityName}');
  }

  void navigateToCommentScreen(BuildContext context) {
    Routemaster.of(context).push('/post/${widget.post.id}/comments');
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.post.type == 'image';
    final isTypeText = widget.post.type == 'text';
    final isTypeLink = widget.post.type == 'link';

    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;

    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ).copyWith(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  //user profile picture
                                  GestureDetector(
                                    onTap: () {
                                      navigateToUserProfile(context);
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          widget.post.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            navigatetoCommunity(context);
                                          },
                                          child: Text(
                                            'c/${widget.post.communityName}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          'u/${widget.post.username}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(widget.post.title,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold)),
                          ),
                          if (isTypeImage)
                            //display image in proportion to 35% of the device height
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                widget.post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: AnyLinkPreview(
                                  link: widget.post.link!,
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                )),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  widget.post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      upvotePost();
                                    },
                                    icon: Icon(
                                      Constants.up,
                                      size: 30,
                                      //if user upvoted, turn upvote button red
                                      color:
                                          widget.post.upvotes.contains(user.uid)
                                              ? Pallete.redColor
                                              : null,
                                    ),
                                  ),
                                  Text(
                                    '${widget.post.upvotes.length - widget.post.downvotes.length}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      downvotePost();
                                    },
                                    icon: Icon(
                                      Constants.down,
                                      size: 30,
                                      //if user upvoted, turn upvote button red
                                      color: widget.post.downvotes
                                              .contains(user.uid)
                                          ? Pallete.blueColor
                                          : null,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      navigateToCommentScreen(context);
                                    },
                                    icon: const Icon(Icons.comment),
                                  ),
                                  Text(
                                    '${widget.post.commentCount}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              //if user is a mod of the community, show the edit button
                              ref
                                  .watch(getCommunityByNameProvider(
                                      widget.post.communityName))
                                  .when(
                                    data: (data) {
                                      if (data.mods.contains(user.uid)) {
                                        return IconButton(
                                          onPressed: () {
                                            deletePost(context);
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Pallete.redColor,
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (error, stackTrace) => Text(
                                      error.toString(),
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
