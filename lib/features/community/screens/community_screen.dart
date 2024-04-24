import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/core/common/post_card.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/models/community_model.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (data) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
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
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: ref.watch(getCommunityPostsProvider(name)).when(
                      data: (data) {
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: data[index]);
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    )),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
