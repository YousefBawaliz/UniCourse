// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';

//SearchDelegate is pre-built Class that helps us set up search function, it includes a search button, and suggestions
class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate({
    required this.ref,
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

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
          data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final community = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(community.avatar),
                ),
                title: Text("c/${community.name}"),
                onTap: () {
                  navigateToCommunity(context, community.name);
                },
              );
            },
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }
}
