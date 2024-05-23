import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:url_launcher/url_launcher.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

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

  void savePost() async {
    ref
        .read(postControllerProvider.notifier)
        .savePost(postId: widget.post.id, context: context);
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
    final isTypeResource = widget.post.type == 'Resource';

    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;

    final savedposts = ref.watch(getSavedPostsProvider(user.uid)).maybeWhen(
          data: (posts) => posts,
          orElse: () => [],
        );
    final isPostSaved = savedposts.contains(widget.post.id);

    return GestureDetector(
      onTap: () {
        navigateToCommentScreen(context);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          navigatetoCommunity(context);
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                navigateToUserProfile(context);
                                              },
                                              child: Text(
                                                'u/${widget.post.username}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),

                                      ///
                                      ///save button:
                                      ///
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        transitionBuilder: (Widget child,
                                            Animation<double> animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: IconButton(
                                          key: ValueKey<bool>(isPostSaved),
                                          onPressed: () {
                                            savePost();
                                          },
                                          icon: Icon(
                                            isPostSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            ///
                            ///Title of the post
                            ///
                            GestureDetector(
                              onTap: () {
                                navigateToCommentScreen(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  widget.post.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              //display image in proportion to 35% of the device height
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
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
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    widget.post.description!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            if (isTypeResource)
                              GestureDetector(
                                onTap: () {
                                  launch(widget.post.link!);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.download),
                                      const SizedBox(width: 10),
                                      Text(
                                        widget.post.title,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: IconButton(
                                        key: ValueKey<bool>(widget.post.upvotes
                                            .contains(user.uid)),
                                        onPressed: () {
                                          upvotePost();
                                        },
                                        icon: Icon(
                                          Constants.up,
                                          size: 30,
                                          //if user upvoted, turn upvote button red
                                          color: widget.post.upvotes
                                                  .contains(user.uid)
                                              ? Pallete.redColor
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${widget.post.upvotes.length - widget.post.downvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: IconButton(
                                        key: ValueKey<bool>(widget
                                            .post.downvotes
                                            .contains(user.uid)),
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
                                      ),
                                    ),
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
                                //if user is a mod of the community, show the delete button
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
                ),
              ],
            ),
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          Divider(
            height: 1,
            thickness: 0.3,
            color: currentTheme.textTheme.bodyMedium!.color,
          ),
        ],
      ),
    );
  }
}
