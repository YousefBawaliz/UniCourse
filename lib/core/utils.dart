import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//simple snackBar to show errors and stuff
void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}

Future<FilePickerResult?> pickResource() async {
  final resource = await FilePicker.platform.pickFiles(type: FileType.any);
  return resource;
}
