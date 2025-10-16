import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/group.dart';
import '../../models/in_tool/prompt.dart';
import '../../models/notifications/prompt_notification.dart';
import '../../models/notifications/tool_notification.dart';
import '../../models/profile.dart';
import '../../models/tool.dart';
import '../../providers/ai_diary_provider.dart';
import '../../services/supabase_tables.dart';
import '../../system/constants.dart';
import '../../widgets/buttons.dart';
import '../../widgets/texts.dart';
import '../../widgets/toast.dart';

class PromptShareModal extends StatelessWidget {
  final Prompt prompt;
  final PromptNotification promptNotification;
  final Profile owner;
  final Tool tool;

  const PromptShareModal({super.key, required this.prompt, required this.owner, required this.promptNotification, required this.tool});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.9,
      decoration: BoxDecoration(
        color: AppColors.primaryBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: (){context.pop();}, child: reusableText(text: 'SKIP', fontWeight: FontWeight.w500))
              ],
            ),

            reusableText(text: 'Shared Prompt to you from ${owner.username}', fontSize: 20, fontWeight: FontWeight.bold, textAlign: TextAlign.start),

            const SizedBox(height: 10),

            reusableText(text: prompt.description, fontWeight: FontWeight.w600),

            const SizedBox(height: 8),

            reusableText(text: prompt.prompt, maxLines: 100),

            const SizedBox(height: 10),

            if(promptNotification.accepted == null)
              reusableText(text: 'This prompt is built for ${tool.name}. If you do not have this tool, it will be automatically added to your diary', maxLines: 5, fontSize: 14, color: AppColors.dashaSignatureColor),

            SizedBox(height: 10,),

            promptNotification.accepted == null
              ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shortActionButton(
                    onPressed: () async {
                      final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
                      await aiDiaryProvider.getJournalPromptToDiary(prompt: prompt);

                      await client.from(SupabaseTables.prompt_notifications.name).update({'accepted': true}).eq('id', promptNotification.id);


                      if(context.mounted){
                        context.pop();
                      }

                      showToast('Prompt added to ${tool.name} in diary');

                    },
                    size: size,
                    text: 'Accept',
                    buttonColor: AppColors.dashaSignatureColor
                ),
                shortActionButton(
                  onPressed: () async {
                    context.pop();
                    await client.from(SupabaseTables.prompt_notifications.name).update({'accepted': false}).eq('id', promptNotification.id);
                  },
                  size: size,
                  text: 'Reject',
                  buttonColor: Colors.transparent,
                ),
              ],
            )
              : Container(
                width: size.width*0.85,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: promptNotification.accepted == true ? AppColors.confirmColor.withAlpha(26) : AppColors.warningColor.withAlpha(26)
                ),
                child: Center(
                  child: reusableText(
                    text: promptNotification.accepted == true ? 'Prompt added' : 'Prompt rejected',
                    fontWeight: FontWeight.w600,
                    color: promptNotification.accepted == true ? AppColors.confirmColor : AppColors.warningColor),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


class ToolShareModal extends StatelessWidget {
  final ToolNotification toolNotification;
  final Tool tool;
  final Group group;
  final Profile sender;

  const ToolShareModal({super.key, required this.toolNotification, required this.group, required this.tool, required this.sender});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.9,
      decoration: BoxDecoration(
        color: AppColors.primaryBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: (){context.pop();}, child: reusableText(text: 'SKIP', fontWeight: FontWeight.w500))
              ],
            ),

            reusableText(text: 'Shared Tool to you from ${sender.username}', fontSize: 20, fontWeight: FontWeight.bold),

            const SizedBox(height: 10),

            reusableText(text: tool.name, fontWeight: FontWeight.w600),

            const SizedBox(height: 4),

            reusableText(text: group.name),

            const SizedBox(height: 20),


            toolNotification.accepted == null
              ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shortActionButton(
                    onPressed: () async {
                      final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
                      await aiDiaryProvider.addToolToDiary(tool: tool);

                      await client.from(SupabaseTables.tool_notifications.name).update({'accepted': true}).eq('id', toolNotification.id);


                      if(context.mounted){
                        context.pop();
                      }

                      showToast('${tool.name} added to diary');

                    },
                    size: size,
                    text: 'Accept',
                    buttonColor: AppColors.dashaSignatureColor
                ),

                shortActionButton(
                  onPressed: () async {
                    context.pop();
                    await client.from(SupabaseTables.tool_notifications.name).update({'accepted': false}).eq('id', toolNotification.id);
                  },
                  size: size,
                  text: 'Reject',
                  buttonColor: Colors.transparent,
                ),
              ],
            )
              : Container(
              width: size.width*0.85,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: toolNotification.accepted == true ? AppColors.confirmColor.withAlpha(26) : AppColors.warningColor.withAlpha(26)
              ),
              child: Center(
                child: reusableText(
                    text: toolNotification.accepted == true ? 'Prompt added' : 'Prompt rejected',
                    fontWeight: FontWeight.w600,
                    color: toolNotification.accepted == true ? AppColors.confirmColor : AppColors.warningColor),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


}