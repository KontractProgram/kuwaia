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

// The class definition changes from StatelessWidget to StatefulWidget
class PromptShareModal extends StatefulWidget {
  final Prompt prompt;
  final PromptNotification promptNotification;
  final Profile owner;
  final Tool tool;

  const PromptShareModal({
    super.key,
    required this.prompt,
    required this.owner,
    required this.promptNotification,
    required this.tool
  });

  @override
  State<PromptShareModal> createState() => _PromptShareModalState();
}

class _PromptShareModalState extends State<PromptShareModal> {
  // 1. Local state variable to track the acceptance status
  // Initialize it with the existing status from the notification object.
  bool? _acceptedStatus;

  @override
  void initState() {
    super.initState();
    _acceptedStatus = widget.promptNotification.accepted;
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return Container(
      // ... (rest of the container setup is the same)
      height: size.height * 0.9,
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
                TextButton(onPressed: () { context.pop(); }, child: reusableText(text: 'SKIP', fontWeight: FontWeight.w500))
              ],
            ),

            reusableText(text: 'Shared Prompt to you from ${widget.owner.username}', fontSize: 20, fontWeight: FontWeight.bold, textAlign: TextAlign.start),

            const SizedBox(height: 10),

            reusableText(text: widget.prompt.description, fontWeight: FontWeight.w600),

            const SizedBox(height: 8),

            reusableText(text: widget.prompt.prompt, maxLines: 100),

            const SizedBox(height: 10),

            // Use the local state variable _acceptedStatus
            if (_acceptedStatus == null)
              reusableText(text: 'This prompt is built for ${widget.tool.name}. If you do not have this tool, it will be automatically added to your diary', maxLines: 5, fontSize: 14, color: AppColors.dashaSignatureColor),

            SizedBox(height: 10),

            // Use the local state variable _acceptedStatus
            _acceptedStatus == null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Accept Button Logic
                shortActionButton(
                    onPressed: () async {
                      final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
                      await aiDiaryProvider.getJournalPromptToDiary(prompt: widget.prompt);

                      // Update the database
                      await client.from(SupabaseTables.prompt_notifications.name).update({'accepted': true}).eq('id', widget.promptNotification.id);

                      // 2. Update the local state and trigger a rebuild
                      setState(() {
                        _acceptedStatus = true;
                      });

                      showToast('Prompt added to ${widget.tool.name} in diary');

                      // We pop after the setState to show the status, otherwise it closes immediately
                      // If you want it to close immediately, move context.pop() here and remove setState.
                      // Since you want to show the 'Prompt added' state, we'll keep the pop() commented or move it out.
                      // context.pop();
                    },
                    size: size,
                    text: 'Accept',
                    buttonColor: AppColors.dashaSignatureColor
                ),
                // Reject Button Logic
                shortActionButton(
                  onPressed: () async {
                    // Update the database
                    await client.from(SupabaseTables.prompt_notifications.name).update({'accepted': false}).eq('id', widget.promptNotification.id);

                    // 3. Update the local state and trigger a rebuild
                    setState(() {
                      _acceptedStatus = false;
                    });

                    // We pop after the setState for the same reason
                    // context.pop();
                  },
                  size: size,
                  text: 'Reject',
                  buttonColor: Colors.transparent,
                ),
              ],
            )
            // Display Accepted/Rejected Container
                : Container(
              width: size.width * 0.85,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Use the local state variable _acceptedStatus
                  color: _acceptedStatus == true ? AppColors.confirmColor.withAlpha(26) : AppColors.warningColor.withAlpha(26)
              ),
              child: Center(
                child: reusableText(
                  // Use the local state variable _acceptedStatus
                    text: _acceptedStatus == true ? 'Prompt added' : 'Prompt rejected',
                    fontWeight: FontWeight.w600,
                    color: _acceptedStatus == true ? AppColors.confirmColor : AppColors.warningColor
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


class ToolShareModal extends StatefulWidget {
  final ToolNotification toolNotification;
  final Tool tool;
  final Group group;
  final Profile sender;

  const ToolShareModal({
    super.key,
    required this.toolNotification,
    required this.group,
    required this.tool,
    required this.sender
  });

  @override
  State<ToolShareModal> createState() => _ToolShareModalState();
}

class _ToolShareModalState extends State<ToolShareModal> {
  // Local state variable to track the acceptance status
  bool? _acceptedStatus;

  @override
  void initState() {
    super.initState();
    // Initialize with the current status from the notification object
    _acceptedStatus = widget.toolNotification.accepted;
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.9,
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
                TextButton(onPressed: () { context.pop(); }, child: reusableText(text: 'SKIP', fontWeight: FontWeight.w500))
              ],
            ),

            // Use widget.sender
            reusableText(text: 'Shared Tool to you from ${widget.sender.username}', fontSize: 20, fontWeight: FontWeight.bold),

            const SizedBox(height: 10),

            // Use widget.tool
            reusableText(text: widget.tool.name, fontWeight: FontWeight.w600),

            const SizedBox(height: 4),

            // Use widget.group
            reusableText(text: widget.group.name),

            const SizedBox(height: 20),

            // Use the local state variable _acceptedStatus
            _acceptedStatus == null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Accept Button Logic
                shortActionButton(
                    onPressed: () async {
                      final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
                      // Use widget.tool
                      await aiDiaryProvider.addToolToDiary(tool: widget.tool);

                      // Update the database
                      await client.from(SupabaseTables.tool_notifications.name)
                      // Use widget.toolNotification
                          .update({'accepted': true}).eq('id', widget.toolNotification.id);

                      // 1. Update the local state and trigger a rebuild
                      setState(() {
                        _acceptedStatus = true;
                      });

                      // Use widget.tool
                      showToast('${widget.tool.name} added to diary');

                      // context.pop() is removed here so the user sees the confirmation container
                    },
                    size: size,
                    text: 'Accept',
                    buttonColor: AppColors.dashaSignatureColor
                ),

                // Reject Button Logic
                shortActionButton(
                  onPressed: () async {
                    // Update the database
                    await client.from(SupabaseTables.tool_notifications.name)
                    // Use widget.toolNotification
                        .update({'accepted': false}).eq('id', widget.toolNotification.id);

                    // 2. Update the local state and trigger a rebuild
                    setState(() {
                      _acceptedStatus = false;
                    });

                    // context.pop() is removed here so the user sees the rejection container
                    // If you want it to close immediately on reject, put context.pop() here.
                  },
                  size: size,
                  text: 'Reject',
                  buttonColor: Colors.transparent,
                ),
              ],
            )
            // Display Accepted/Rejected Container
                : Container(
              width: size.width * 0.85,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Use the local state variable _acceptedStatus
                  color: _acceptedStatus == true ? AppColors.confirmColor.withAlpha(26) : AppColors.warningColor.withAlpha(26)
              ),
              child: Center(
                child: reusableText(
                  // Use the local state variable _acceptedStatus
                    text: _acceptedStatus == true ? 'Tool added' : 'Tool rejected', // Corrected text from 'Prompt' to 'Tool'
                    fontWeight: FontWeight.w600,
                    color: _acceptedStatus == true ? AppColors.confirmColor : AppColors.warningColor
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}