// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/features/post/widgets/condensed_post_card.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/models/post_model.dart';

//SearchDelegate is pre-built Class that helps us set up search function, it includes a search button, and suggestions
class SearchPostsDelegate extends SearchDelegate {
  final WidgetRef ref;
  late Algolia algolia;
  final String currentCommunityName;
  SearchPostsDelegate({
    required this.ref,
    required this.algolia,
    required this.currentCommunityName,
  });
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            //Changes the current query string.
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  /// Fetches posts based on a search query.
  ///
  /// The [searchQuery] parameter is used to search for posts in the 'posts_index' index.
  /// Returns a list of [Post] objects that match the search query.
  Future<List<Post>> fetchPosts(searchQuery) async {
    final query = algolia.instance.index('posts_index').query(searchQuery);
    final snap = await query.getObjects();
    final results = snap.hits;

    // return results.map((e) => Post.fromMap(e.data)).toList();
    // return results.map((e) => e.data['objectID']).toList();
    final postIds = results.map((e) => e.data['objectID'].toString()).toList();
    final posts = ref.read(getPostsByIdProvider(postIds).future);
    return posts;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: fetchPosts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return ErrorText(error: snapshot.error.toString());
        } else {
          final results = snapshot.data ?? [];
          final filteredResults = results
              .where((element) => element.communityName == currentCommunityName)
              .toList();
          return ListView.builder(
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              // final post = ref
              //     .read(getPostByIdProvider(results[index].data['objectID']))
              //     .maybeWhen(data: (data) => data, orElse: () => null);
              final post = filteredResults[index];
              // return ListTile(
              //   title: Text(post.title),
              //   onTap: () async {

              //     navigateToCommentScreen(context, post.id);

              //   },
              // );
              return CondensedPostCard(
                post: post,
                navigateToCommentScreen: () {
                  navigateToCommentScreen(context, post.id);
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  void navigateToCommentScreen(BuildContext context, String? postID) {
    Routemaster.of(context).pop();
    Routemaster.of(context).replace('/post/${postID}/comments');
  }
}
