import 'package:flutter/material.dart';
import 'package:kuwaia/models/notifications/prompt_notification.dart';
import 'package:kuwaia/models/notifications/tool_notification.dart';
import 'package:kuwaia/screens/others/notification_modals.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/group.dart';
import '../../../models/in_tool/prompt.dart';
import '../../../models/notifications/app_notification.dart';
import '../../../models/tool.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/profile_service.dart';
import '../../../services/supabase_tables.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchAllNotifications();
    });
  }

  void _showViewNotificationModal({required BuildContext context, required Size size, required AppNotification notification }) async {
    final SupabaseClient client = Supabase.instance.client;
    final np = Provider.of<NotificationProvider>(context, listen: false);
    await np.readNotification(notification);

    if(notification is PromptNotification) {
      final profileService = ProfileService();
      final owner = await profileService.getProfileById(notification.senderId);
      final promptResponse = await client.from(SupabaseTables.profile_tool_prompts.name).select().eq('id', notification.promptId).maybeSingle();
      final prompt = Prompt.fromMap(promptResponse!);
      final toolResponse = await client.from(SupabaseTables.tools.name).select().eq('id', prompt.toolId).maybeSingle();
      final tool = Tool.fromMap(toolResponse!);

      if(context.mounted){
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          backgroundColor: AppColors.primaryBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => PromptShareModal(prompt: prompt, owner: owner!, promptNotification: notification, tool: tool),
        );
      }
    }
    else if(notification is ToolNotification) {
      final profileService = ProfileService();
      final sender = await profileService.getProfileById(notification.senderId);
      final toolResponse = await client.from(SupabaseTables.tools.name).select().eq('id', notification.toolId).maybeSingle();
      final tool = Tool.fromMap(toolResponse!);
      final group = groups.firstWhere((g) => g.id == tool.groupId);

      if(context.mounted){
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          backgroundColor: AppColors.primaryBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => ToolShareModal(group: group, sender: sender!, toolNotification: notification, tool: tool),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: leadingButton(context),
        title: reusableText(text: 'Notifications', fontWeight: FontWeight.w600),
      ),
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(vertical: size.height*0.01, horizontal: size.width*0.05),
          child: Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              if(notificationProvider.isLoading) {
                return Center(child: CircularProgressIndicator(color: AppColors.dashaSignatureColor));
              }

              if (notificationProvider.error != null) {
                return Center(
                  child: Text(
                    notificationProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final notifications = notificationProvider.getSortedNotifications();


              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final timeAgo = formatTimeAgo(notification.createdAt);
                  return Stack(
                    children: [
                      singleTrailCardWidget(
                        leadingIcon: 'main/notificationicon',
                        title: notification.message,
                        subtitle: timeAgo,
                        onPressed: () => _showViewNotificationModal(context: context, size: size, notification: notification)
                      ),

                      if (notification.read == false)
                        Positioned(
                          top: 8,
                          right: 12,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.dashaSignatureColor, // Or your app’s accent color
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

}
