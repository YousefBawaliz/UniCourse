import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uni_course/core/common/error_text.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/core/utils.dart';
import 'package:uni_course/features/auth/controller/auth_controller.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';
import 'package:uni_course/features/home/screens/home_screen.dart';
import 'package:uni_course/features/post/controller/post_controller.dart';
import 'package:uni_course/models/community_model.dart';
import 'package:uni_course/theme/pallete.dart';

import 'package:path/path.dart' as p;

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descreptionController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  List<Community> communities = [];
  //for the current value of the dropDownButton
  Community? selectedCommunity;

  File? bannerFile;
  File? resourceFile;

  @override
  void dispose() {
    titleController.dispose();
    descreptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void selectBannerImage() async {
    final result = await pickImage();

    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  /// Opens a file picker to select a resource file.
  ///
  /// This method prompts the user to pick a resource file and sets the selected file
  /// to the [resourceFile] variable. If a file is selected, the state is updated
  /// to reflect the new selection.
  ///
  /// Throws an exception if the file picker fails to open or if the user cancels
  /// the file selection.
  void selectResourceFile() async {
    final result = await pickResource();

    if (result != null) {
      setState(() {
        resourceFile = File(result.files.first.path!);
      });
    }
  }

  //function to share post depending on it's type and what user has typed
  void sharePost() {
    if (widget.type == 'image' &&
        (bannerFile != null) &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: bannerFile,
            description: descreptionController.text.trim(),
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descreptionController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            description: descreptionController.text.trim(),
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            link: linkController.text.trim(),
          );
    } else if (widget.type == 'resource' &&
        titleController.text.isNotEmpty &&
        resourceFile != null) {
      ref.read(postControllerProvider.notifier).shareResourcePost(
            description: descreptionController.text.trim(),
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: resourceFile,
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    //to check the type of the post
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isTypeResource = widget.type == 'resource';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return PopScope(
      canPop: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Routemaster.of(context).replace('/');
            },
          ),
          title: Text('post ${widget.type}'),
          actions: [
            TextButton(onPressed: sharePost, child: const Text('Share'))
          ],
        ),
        body: isLoading
            ? const Loader()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      maxLength: 30,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: "enter title here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (isTypeImage)
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: currentTheme.textTheme.bodyMedium!.color!,
                          child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: bannerFile != null
                                  ? Image.file(bannerFile!)
                                  : const Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                      ),
                                    )),
                        ),
                      ),
                    if (isTypeResource)
                      GestureDetector(
                        onTap: selectResourceFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .blue, // Change the color to indicate it can be clicked
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: resourceFile != null
                              ? Text(p.basename(resourceFile!.path))
                              : const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.file_copy_outlined,
                                        size: 40,
                                      ),
                                      Text("Upload Resource")
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    // if (isTypeText)
                    //   TextField(
                    //     controller: descreptionController,
                    //     maxLines: 5,
                    //     decoration: const InputDecoration(
                    //       filled: true,
                    //       hintText: "enter description here",
                    //       border: InputBorder.none,
                    //       contentPadding: EdgeInsets.all(18),
                    //     ),
                    //   ),
                    if (isTypeLink)
                      TextField(
                        controller: linkController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: "enter Link here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: descreptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: "enter description here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: const Text(
                          "Select Community",
                        ),
                      ),
                    ),
                    ref.watch(userCommunitiesProvider).when(
                          data: (data) {
                            communities = data;
                            if (data.isEmpty) {
                              return const SizedBox();
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: DropdownButton(
                                padding: const EdgeInsets.only(left: 8),
                                value: selectedCommunity ?? data[0],
                                items: data
                                    .map(
                                      (e) => DropdownMenuItem(
                                        //if no value is selected yet, refer to communities[0]
                                        value: e,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCommunity = value;
                                  });
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        )
                  ],
                ),
              ),
      ),
    );
  }
}
