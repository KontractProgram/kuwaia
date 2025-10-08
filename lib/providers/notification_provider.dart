import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/profile.dart';
import 'package:kuwaia/models/prompt_notification.dart';
import 'package:kuwaia/models/tool.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/in_tool/prompt.dart';
import '../system/constants.dart';

class PromptNotificationProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final List<PromptNotification> _promptNotifications = [];

  List<PromptNotification> get promptNotifications => _promptNotifications;

  /// Subscribe to realtime promptNotifications for the current user
  void subscribe(BuildContext context) {
    final currentUserId = _client.auth.currentUser?.id;
    _client
        .channel('public:prompt_notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'prompt_notifications',
      filter: PostgresChangeFilter(
        column: 'receiver_id',
        value: currentUserId,
        type: PostgresChangeFilterType.eq,
      ),
      callback: (payload) async {
        final profileService = ProfileService();
        final promptNotification = PromptNotification.fromMap(payload.newRecord);
        _promptNotifications.insert(0, promptNotification);
        notifyListeners();

        // Optional: show in-app toast or snack bar
        print('New notification: ${payload.newRecord}');

        final owner = await profileService.getProfileById(promptNotification.senderId);
        final promptResponse = await _client.from('profile_tool_prompts').select().eq('id', promptNotification.promptId).maybeSingle();
        final prompt = Prompt.fromMap(promptResponse!);
        final toolResponse = await _client.from('tools').select().eq('id', prompt.toolId).maybeSingle();
        final tool = Tool.fromMap(toolResponse!);



        showSimpleNotification(
          reusableText(text: 'New prompt shared to you!'),
          leading: FaIcon(FontAwesomeIcons.message),
          background: AppColors.dashaSignatureColor,
          autoDismiss: false,
          slideDismissDirection: DismissDirection.horizontal,
          trailing: TextButton(
            onPressed: () async {
              OverlaySupportEntry.of(context)?.dismiss();

              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.primaryBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _PromptShareModal(prompt: prompt, owner: owner!, promptNotification: promptNotification, tool: tool,)
              );

              await _client.from('prompt_notifications').update({'read': true}).eq('id', promptNotification.id);

            },
            child: reusableText(text: 'VIEW', fontSize: 20, fontWeight: FontWeight.bold)
          )
        );

      },
    ).subscribe();

    print('subscribed for notifications');
  }

  /// Add a notification manually (optional)
  void addPromptNotification(PromptNotification notification) {
    _promptNotifications.insert(0, notification);
    notifyListeners();
  }

  /// Remove a notification (e.g., after accepting/declining)
  void removePromptNotification(PromptNotification notification) {
    _promptNotifications.removeWhere((n) => n.id == notification.id);
    notifyListeners();
  }

  /// Clear all notifications (optional)
  void clearPromptNotifications() {
    _promptNotifications.clear();
    notifyListeners();
  }
}



class _PromptShareModal extends StatelessWidget {
  final Prompt prompt;
  final PromptNotification promptNotification;
  final Profile owner;
  final Tool tool;

  const _PromptShareModal({required this.prompt, required this.owner, required this.promptNotification, required this.tool});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
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

            reusableText(text: 'Shared Prompt to you from ${owner.username}', fontSize: 20, fontWeight: FontWeight.bold),
        
            const SizedBox(height: 10),

            reusableText(text: prompt.description, fontWeight: FontWeight.w600),

            const SizedBox(height: 8),

            reusableText(text: prompt.prompt, maxLines: 100),

            const SizedBox(height: 20),

            reusableText(text: 'This prompt is built for ${tool.name}. If you do not have this tool, it will be automatically added to your diary', maxLines: 5, fontSize: 14),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
                    await aiDiaryProvider.getJournalPromptToDiary(prompt: prompt);
        
                    await client.from('prompt_notifications').update({'accepted': true}).eq('id', promptNotification.id);
        
        
                    if(context.mounted){
                      context.pop();
                    }
        
                    showToast('Prompt added to ${tool.name} in diary');
                  },
                  icon: Icon(Icons.check),
                  label: reusableText(text: 'Accept'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    context.pop();
                    await client.from('notifications').update({'accepted': false}).eq('id', promptNotification.id);
                  },
                  icon: Icon(Icons.close),
                  label: Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
