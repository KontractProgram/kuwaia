import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/custom.dart';
import '../../../models/tool.dart';
import '../../../system/constants.dart';
import '../../../widgets/texts.dart';


class ToolViewScreen extends StatefulWidget {
  final Tool tool;
  const ToolViewScreen({super.key, required this.tool});

  @override
  State<ToolViewScreen> createState() => _ToolViewScreenState();
}

class _ToolViewScreenState extends State<ToolViewScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: reusableText(
          text: widget.tool.name,
          color: AppColors.headingTextColor,
          fontSize: 16,
          maxLines: 1,
          fontWeight: FontWeight.w700
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
                  //my prompts
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.message,
                    title: 'My Prompts',
                    onPressed: () => context.push('/my_prompts', extra: {'tool': widget.tool})
                  ),
                  //my Notes
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.noteSticky,
                    title: 'My Notes',
                    onPressed: () => context.push('/my_notes', extra: {'tool': widget.tool})
                  ),
                  //my Videos
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.video,
                    title: 'My Videos',
                    onPressed: () => context.push('/my_videos', extra: {'tool': widget.tool})
                  ),
                  //Official Use Case
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.signature,
                    title: 'Official Use Case',
                    onPressed: () => context.push('/official_use_case', extra: {'tool': widget.tool})
                  ),
                  //Log Details
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.clockRotateLeft,
                    title: 'Log Details',
                    onPressed: () => context.push('/log_details', extra: {'tool': widget.tool})
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}
