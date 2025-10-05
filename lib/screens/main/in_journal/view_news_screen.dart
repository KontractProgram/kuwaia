import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/buttons.dart';
import '../../../models/community/news.dart';
import '../../../system/constants.dart';
import '../../../widgets/texts.dart';

class ViewNewsScreen extends StatelessWidget {
  final News news;

  const ViewNewsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Split content into paragraphs wherever ".  " occurs
    final paragraphs = news.content.split(".  ");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: reusableText(
          text: 'News',
          color: AppColors.headingTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reusableText(
                  text: news.title,
                  color: AppColors.headingTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 20),

                // Render each paragraph separately
                ...paragraphs.map((para) {
                  // Add back the missing period if it was removed by split
                  final clean = para.trim();
                  final formatted = clean.endsWith('.') ? clean : '$clean.';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: reusableText(
                      text: formatted,
                      color: AppColors.headingTextColor,
                      fontSize: 12,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
