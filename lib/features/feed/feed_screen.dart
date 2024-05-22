import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/post/widgets/post_card.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //we're fetching the user communities to then provide them to userPostProvider.
    return ref.watch(userCommunitiesProvider).when(
          data: (data) => ref.watch(userPostProvider(data)).when(
                data: (data) {
                  //data here refers to post
                  //listView Builder to display the posts using PostCard
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final post = data[index];
                      return PostCard(post: post);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(error: error.toString());
                },
                loading: () => const Loader(),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
