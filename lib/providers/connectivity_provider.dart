import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:overlay_support/overlay_support.dart';

import '../system/constants.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _hasInternet = true;
  OverlaySupportEntry? _overlayEntry;

  bool get hasInternet => _hasInternet;

  ConnectivityProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // initial check (normalize any return type)
    try {
      final dynamic result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(_normalize(result));
    } catch (_) {
      _updateConnectionStatus([]);
    }

    // subscribe to changes (some versions emit ConnectivityResult, others a List)
    _subscription = _connectivity.onConnectivityChanged.listen((dynamic result) {
      _updateConnectionStatus(_normalize(result));
    });
  }

  // Normalize different possible return shapes into a List<ConnectivityResult>
  List<ConnectivityResult> _normalize(dynamic result) {
    if (result == null) return [];
    if (result is ConnectivityResult) return [result];
    if (result is List<ConnectivityResult>) return result;
    if (result is Iterable<ConnectivityResult>) {
      return result.cast<ConnectivityResult>().toList();
    }
    return [];
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool previouslyConnected = _hasInternet;

    // consider these types as providing internet access
    final bool connected = results.any((r) =>
    r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn ||
        r == ConnectivityResult.bluetooth ||
        r == ConnectivityResult.other);

    _hasInternet = connected;

    if (previouslyConnected != _hasInternet) {
      if (!_hasInternet) {
        _showNoInternetBanner();
      } else {
        _dismissBanner();
      }
      notifyListeners();
    }
  }

  void _showNoInternetBanner() {
    if (_overlayEntry != null) return;
    _overlayEntry = showSimpleNotification(
      reusableText(
        text: "No Internet Connection",
        fontWeight: FontWeight.w600,
      ),
      leading: Icon(Icons.signal_wifi_connected_no_internet_4, color: AppColors.bodyTextColor,),
      background: AppColors.warningColor,
      autoDismiss: false,
      slideDismissDirection: DismissDirection.none,
    );
  }

  void _dismissBanner() {
    try {
      _overlayEntry?.dismiss();
    } catch (_) {
      // ignore dismiss errors
    } finally {
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    // make sure banner is gone
    _overlayEntry?.dismiss();
    _overlayEntry = null;
    super.dispose();
  }
}
