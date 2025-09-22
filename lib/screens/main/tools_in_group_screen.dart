import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/group.dart';
import '../../models/tool.dart';
import '../../providers/auth_provider.dart';
import '../../system/constants.dart';
import '../../widgets/texts.dart';

class ToolsInGroupScreen extends StatefulWidget {
  final Group group;
  final List<Tool> tools;
  const ToolsInGroupScreen({super.key, required this.group, required this.tools});

  @override
  State<ToolsInGroupScreen> createState() => _ToolsInGroupScreenState();
}

class _ToolsInGroupScreenState extends State<ToolsInGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: reusableText(
            text: '${widget.group.name} Tools',
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
                widget.tools.isEmpty
                    ? Container(
                  padding: EdgeInsets.only(top: size.height*0.2),
                  child: Lottie.asset(emptyDiary, width: size.width*0.6),
                )
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.tools.length,
                    itemBuilder: (context, index) {
                      final tool = widget.tools[index];
                      final logo = '';

                      final inDiary = context.read<AiDiaryProvider>().isToolInDiary(tool);
                      print('tool ${tool.name} in diary $inDiary');

                      return toolCardWidget(
                        context: context,
                        tool: tool,
                        group: widget.group,
                        inDiary: inDiary,
                        logo: logo,
                        onBookMarkPressed: () async {
                          print('333333333');
                          final profileId = context.read<AuthProvider>().profile!.id;
                          print(profileId);
                          if(inDiary) {
                            print('2222222222');
                            await context.read<AiDiaryProvider>().deleteToolFromDiary(profileId: profileId, toolId: tool.id);
                          } else {
                            print('000000000000');
                            await context.read<AiDiaryProvider>().addToolToDiary(profileId: profileId, tool: tool);
                          }

                          setState(() {});
                        }
                      );
                    }
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
