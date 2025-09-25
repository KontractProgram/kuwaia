import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tool.dart';

class ToolsProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _allTools;
  bool _isLoading = true;
  String? _error;

  List<Tool>? get allTools => _allTools;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTools() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final toolsResponse = await _client.from('tools').select();

      final toolsList = List<Map<String, dynamic>>.from(toolsResponse);

      _allTools = toolsList.map((map) => Tool.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔍 Get all tools belonging to a specific group
  List<Tool> getToolsByGroup(int groupId) {
    if (_allTools == null) return [];
    return _allTools!.where((tool) => tool.groupId == groupId).toList();
  }
}
