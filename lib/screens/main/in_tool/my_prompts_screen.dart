import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/tool.dart';
import '../../../system/constants.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/texts.dart';

class MyPromptsScreen extends StatefulWidget {
  final Tool tool;
  const MyPromptsScreen({super.key, required this.tool});

  @override
  State<MyPromptsScreen> createState() => _MyPromptsScreenState();
}

class _MyPromptsScreenState extends State<MyPromptsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: Center(child: reusableText(
            text: 'My Saved Prompts',
            color: AppColors.headingTextColor,
            fontSize: 16,
            maxLines: 1,
            fontWeight: FontWeight.w700
        ),
        ),
      ),

      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.02),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shortActionButton(
                      text: "+ Add Prompt",
                      size: size,
                      onPressed: () {
                        print('add prompt');
                      }
                    ),
                    SizedBox(height: size.height*0.02,),
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }

}
