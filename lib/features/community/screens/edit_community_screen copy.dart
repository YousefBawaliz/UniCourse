import 'dart:io';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/core/constants/constants.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        profileFile = File(result.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        community: community,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final _isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (data) => Scaffold(
            backgroundColor: currentTheme.colorScheme.background,
            appBar: AppBar(
              title: const Text("Edit community"),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {
                    save(data);
                  },
                  child: const Text("save"),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: Loader())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color:
                                      currentTheme.textTheme.bodyMedium!.color!,
                                  child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : data.banner.isEmpty ||
                                                  data.banner ==
                                                      Constants.bannerDefault
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ),
                                                )
                                              : Image.network(data.banner)),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: GestureDetector(
                                  onTap: selectProfileImage,
                                  child: profileFile != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(profileFile!),
                                          radius: 32,
                                        )
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data.avatar),
                                          radius: 32,
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
