import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/post/widgets/post_card.dart';
import 'package:uni_course/core/enums/enums.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/features/home/delegates/search_community_delegate.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/theme/pallete.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  SortOption? _sortOption = SortOption.mostRecent;

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/${widget.name}');
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Routemaster.of(context).push('/add-post');
          },
          child: const Icon(Icons.add),
        ),
        body: ref.watch(getCommunityByNameProvider(widget.name)).when(
              data: (data) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      actions: [
                        IconButton(
                          onPressed: () {
                            //pre built function that Shows a full screen search page and returns the search result selected by the user when the page is closed.
                            showSearch(
                                context: context,
                                delegate: SearchCommunityDelegate(ref: ref));
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.network(
                            data.banner,
                            fit: BoxFit.cover,
                          ))
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(data.avatar),
                                radius: 35,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "c/${data.name}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                data.mods.contains(user.uid)
                                    ? OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () {
                                          navigateToModTools(context);
                                        },
                                        child: const Text("Mod Tools"),
                                      )
                                    : OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () {
                                          joinCommunity(ref, data, context);
                                        },
                                        child: Text(
                                            data.members.contains(user.uid)
                                                ? "joined"
                                                : "Join"),
                                      ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text('${data.members.length} members'),
                            ),
                            const SizedBox(
                              height: 50,
                              child: TabBar(
                                dividerHeight: 0,
                                padding: EdgeInsets.all(0),
                                indicatorColor: Colors
                                    .blue, // Change this to your preferred indicator color
                                labelColor: Colors
                                    .blue, // Change this to your preferred label color
                                unselectedLabelColor: Colors
                                    .grey, // Change this to your preferred unselected label color
                                indicatorSize: TabBarIndicatorSize.label,
                                labelStyle: TextStyle(
                                    fontSize:
                                        12.0), // Change this to your preferred font size
                                tabs: [
                                  Tab(
                                      icon: Icon(Icons.home, size: 20),
                                      text:
                                          "Home"), // Change the icon size as needed
                                  Tab(
                                      icon: Icon(Icons.book, size: 20),
                                      text:
                                          "Resources"), // Change the icon size as needed
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: TabBarView(
                  children: [
                    ref
                        .watch(_sortOption == SortOption.mostRecent
                            ? getCommunityPostsProvider(widget.name)
                            : getTopCommunityPostsProvider(widget.name))
                        .when(
                          data: (data) {
                            return Column(children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: const Color.fromARGB(255, 29, 25, 25),
                                  padding: const EdgeInsets.only(
                                      left: 16, bottom: 0),
                                  margin:
                                      const EdgeInsets.only(top: 0, bottom: 0),
                                  child: DropdownButton<SortOption>(
                                    underline: Container(),
                                    value: _sortOption,
                                    icon: Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: const Icon(Icons.sort)),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _sortOption = newValue;
                                      });
                                    },
                                    items: <SortOption>[
                                      SortOption.mostUpvoted,
                                      SortOption.mostRecent,
                                    ].map<DropdownMenuItem<SortOption>>(
                                        (SortOption value) {
                                      return DropdownMenuItem<SortOption>(
                                        value: value,
                                        child: Text(
                                            value == SortOption.mostUpvoted
                                                ? 'Most Upvoted'
                                                : 'Most Recent'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return PostCard(post: data[index]);
                                  },
                                ),
                              ),
                            ]);
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        ),
                    Container(
                      child: const Center(
                        child: Text('Resources Screen'),
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
