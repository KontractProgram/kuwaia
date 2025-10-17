import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/supabase_tables.dart';
import '../system/constants.dart';
import '../widgets/texts.dart';

class VersionProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  DateTime? _releaseDateTime;
  DateTime? _mustUseDateTime;
  String? _iOSAppStoreUrl;
  String? _androidPlayStoreUrl;

  DateTime? get releaseDateTime => _releaseDateTime;
  DateTime? get mustUseDateTime => _mustUseDateTime;

  // Helper to open the correct store link based on platform
  void _launchStoreUrl(BuildContext context) async {
    // FIX 1: Correctly use Theme.of(context).platform for store URL resolution.
    // FIX 2: Check if the URLs are available (not null or empty).

    if (_iOSAppStoreUrl != null && _androidPlayStoreUrl != null) {
      String url = (defaultTargetPlatform == TargetPlatform.iOS)
          ? _iOSAppStoreUrl!
          : _androidPlayStoreUrl!;

      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } else {
      debugPrint('Store URLs not fetched or available.');
    }
  }

  // Soft Update Notification (Dismissable but Persistent)
  void _showUpdateNotification(BuildContext context) {
    showSimpleNotification(
        reusableText(text: 'A new app update is available!', textAlign: TextAlign.start),
        leading: const FaIcon(FontAwesomeIcons.circleUp),
        background: AppColors.secondaryAccentColor,
        autoDismiss: false, // Not auto dismissable
        slideDismissDirection: DismissDirection.horizontal, // Can be swiped away

        // FIX: Use Builder to get the context inside the Overlay
        trailing: Builder(
            builder: (innerContext) { // innerContext is the context of the TextButton inside the Overlay
              return TextButton(
                onPressed: () {
                  // 1. Dismiss using the innerContext (the one inside the notification)
                  OverlaySupportEntry.of(innerContext)?.dismiss();
                  // 2. Launch URL using the original context (for Theme/Platform check)
                  _launchStoreUrl(context);
                },
                child: reusableText(
                  text: 'UPDATE',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyTextColor,
                ),
              );
            }
        )
    );
  }

  void _showMustUseUpdateScreen(BuildContext context){
    showSimpleNotification(
        reusableText(text: 'This version is already outdated, some features may not work well. Please update this now ASAP', textAlign: TextAlign.start, maxLines: 4, fontSize: 14),
        leading: const FaIcon(FontAwesomeIcons.circleUp),
        background: AppColors.warningColor,
        autoDismiss: false, // Not auto dismissable
        slideDismiss: false,
        // FIX: Use Builder to get the context inside the Overlay
        trailing: Builder(
            builder: (innerContext) { // innerContext is the context of the TextButton inside the Overlay
              return TextButton(
                onPressed: () {
                  // 1. Dismiss using the innerContext (the one inside the notification)
                  OverlaySupportEntry.of(innerContext)?.dismiss();
                  // 2. Launch URL using the original context (for Theme/Platform check)
                  _launchStoreUrl(context);
                },
                child: reusableText(
                  text: 'UPDATE',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyTextColor,
                ),
              );
            }
        )
    );
  }

  // --- Main Fetch and Check Function ---
  // The fetch logic now includes populating the store URLs from the record.
  Future<void> fetchVersionDates(BuildContext context) async {
    try{
      // 1. Fetch dates and URLs
      final response = await _client.from(SupabaseTables.versions.name).select().maybeSingle();

      if (response == null) {
        debugPrint("Version record not found or table is empty.");
        return;
      }

      _releaseDateTime = DateTime.parse(response['release_date']);
      _mustUseDateTime = DateTime.parse(response['must_use_date']);

      // NEW: Fetch store URLs from the record
      _iOSAppStoreUrl = response['ios_store_url'];
      _androidPlayStoreUrl = response['android_store_url'];

      debugPrint('Release time: $_releaseDateTime');
      debugPrint('must use time: $_mustUseDateTime');
      debugPrint('iOS URL: $_iOSAppStoreUrl');
      debugPrint('Android URL: $_androidPlayStoreUrl');

      final now = DateTime.now();

      notifyListeners();

      // 2. Check mustUse Date (Highest Priority)
      if (_mustUseDateTime != null && now.isAfter(_mustUseDateTime!)) {
        if(context.mounted) _showMustUseUpdateScreen(context);
      }

      // 3. Check Release Date (Soft Notification)
      else if (_releaseDateTime != null && now.isAfter(_releaseDateTime!)) {
        if(context.mounted) _showUpdateNotification(context);
      } else {
        debugPrint('the version is good and running');
      }

      notifyListeners();
    } catch(e) {
      debugPrint('Error fetching version dates: ${e.toString()}');
    }
  }
}