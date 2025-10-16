import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/notifications/app_notification.dart';
import 'package:kuwaia/models/notifications/tool_notification.dart';
import 'package:kuwaia/models/profile.dart';
import 'package:kuwaia/models/notifications/prompt_notification.dart';
import 'package:kuwaia/models/tool.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import '../models/in_tool/prompt.dart';
import '../screens/others/notification_modals.dart';
import '../services/supabase_tables.dart';
import '../system/constants.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<PromptNotification> _promptNotifications = [];
  List<ToolNotification> _toolNotifications = [];
  List<AppNotification> _allNotifications = [];
  bool _isLoading = true;
  String? _error;


  List<PromptNotification>? get promptNotifications => _promptNotifications;
  List<ToolNotification>? get toolNotification => _toolNotifications;
  List<AppNotification>? get allNotifications => _allNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppNotification> getSortedNotifications() {
    final sorted = List<AppNotification>.from(_allNotifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  void _sortNotifications() {
    _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> fetchAllNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final id = _client.auth.currentUser!.id;

      final promptNotificationResponse = await _client
                                          .from(SupabaseTables.prompt_notifications.name)
                                          .select()
                                          .eq('receiver_id', id);

      _promptNotifications = promptNotificationResponse.isNotEmpty
          ? List<Map<String, dynamic>>.from(promptNotificationResponse)
          .map((map) => PromptNotification.fromMap(map))
          .toList()
          : <PromptNotification>[];

      final toolNotificationResponse = await _client
          .from(SupabaseTables.tool_notifications.name)
          .select()
          .eq('receiver_id', id);

      _toolNotifications = toolNotificationResponse.isNotEmpty
          ? List<Map<String, dynamic>>.from(toolNotificationResponse)
          .map((map) => ToolNotification.fromMap(map))
          .toList()
          : <ToolNotification>[];

      _allNotifications = [
        ..._promptNotifications,
        ..._toolNotifications,
      ];

      _sortNotifications();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> readNotification(AppNotification notification) async {
    try {
      String table;
      if (notification is PromptNotification) {
        table = SupabaseTables.prompt_notifications.name;
      } else if (notification is ToolNotification) {
        table = SupabaseTables.tool_notifications.name;
      } else {
        throw Exception('Unknown notification type');
      }

      await _client
          .from(table)
          .update({'read': true})
          .eq('id', notification.id);

      notification.read = true;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }


  /// Subscribe to realtime promptNotifications for the current user
  void subscribePromptShare(BuildContext context) {
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
        _allNotifications.insert(0, promptNotification);
        notifyListeners();

        // Optional: show in-app toast or snack bar
        print('New notification: ${payload.newRecord}');

        final owner = await profileService.getProfileById(promptNotification.senderId);
        final promptResponse = await _client.from(SupabaseTables.profile_tool_prompts.name).select().eq('id', promptNotification.promptId).maybeSingle();
        final prompt = Prompt.fromMap(promptResponse!);
        final toolResponse = await _client.from(SupabaseTables.tools.name).select().eq('id', prompt.toolId).maybeSingle();
        final tool = Tool.fromMap(toolResponse!);

        OverlaySupportEntry? entry;

        entry = showSimpleNotification(
          reusableText(text: 'New prompt shared to you!', textAlign: TextAlign.start),
          leading: FaIcon(FontAwesomeIcons.message),
          background: AppColors.dashaSignatureColor,
          autoDismiss: false,
          slideDismissDirection: DismissDirection.horizontal,
          trailing: TextButton(
            onPressed: () async {
              entry?.dismiss();
              print(promptNotification.id);
              print(promptNotification.senderId);

              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.primaryBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => PromptShareModal(prompt: prompt, owner: owner!, promptNotification: promptNotification, tool: tool,)
              );

              await _client.from(SupabaseTables.prompt_notifications.name).update({'read': true}).eq('id', promptNotification.id);

            },
            child: reusableText(text: 'VIEW', fontSize: 20, fontWeight: FontWeight.bold)
          )
        );
      },
    ).subscribe();

    print('subscribed for prompt share notifications');
  }

  void subscribeToolShare(BuildContext context) {
    final currentUserId = _client.auth.currentUser?.id;
    _client
        .channel('public:tool_notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tool_notifications',
      filter: PostgresChangeFilter(
        column: 'receiver_id',
        value: currentUserId,
        type: PostgresChangeFilterType.eq,
      ),
      callback: (payload) async {
        final toolNotification = ToolNotification.fromMap(payload.newRecord);
        _toolNotifications.insert(0, toolNotification);
        _allNotifications.insert(0, toolNotification);
        notifyListeners();

        // Optional: show in-app toast or snack bar
        print('New notification: ${payload.newRecord}');

        final profileService = ProfileService();
        final sender = await profileService.getProfileById(toolNotification.senderId);
        final toolResponse = await _client.from(SupabaseTables.tools.name).select().eq('id', toolNotification.toolId).maybeSingle();
        final tool = Tool.fromMap(toolResponse!);
        final group = groups.firstWhere((g) => g.id == tool.groupId);

        OverlaySupportEntry? entry;

        entry = showSimpleNotification(
            reusableText(text: 'New tool shared to you!', textAlign: TextAlign.start),
            leading: FaIcon(FontAwesomeIcons.message),
            background: AppColors.dashaSignatureColor,
            autoDismiss: false,
            slideDismissDirection: DismissDirection.horizontal,
            trailing: TextButton(
                onPressed: () async {
                  entry?.dismiss();

                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.primaryBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => ToolShareModal(toolNotification: toolNotification, group: group,  tool: tool, sender: sender!)
                  );

                  await _client.from(SupabaseTables.tool_notifications.name).update({'read': true}).eq('id', tool.id);

                },
                child: reusableText(text: 'VIEW', fontSize: 20, fontWeight: FontWeight.bold)
            )
        );

      },
    ).subscribe();

    print('subscribed for tool share notifications');
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