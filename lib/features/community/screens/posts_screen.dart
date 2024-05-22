import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: const Center(
      child: Text('Posts Screen'),
    ));
  }
}
