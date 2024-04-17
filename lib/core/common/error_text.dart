//this is gonna be used repeatidly in the application whenver we use providers and such

import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(error),
    );
  }
}
