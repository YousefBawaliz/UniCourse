import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_course/core/common/loader.dart';
import 'package:uni_course/features/community/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _communityTextEditingController = TextEditingController();

  @override
  void dispose() {
    _communityTextEditingController.dispose();
    super.dispose();
  }

  void createCommunity() {
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(_communityTextEditingController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a community"),
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Community name')),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "r/Community_name",
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 21,
                    controller: _communityTextEditingController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: createCommunity,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "create Community",
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
