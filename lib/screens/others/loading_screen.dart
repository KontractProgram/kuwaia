import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.dashaSignatureColor),
      ),
    );
  }
}