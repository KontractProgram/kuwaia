import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tool.dart';

class AiDiaryProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _diary;
  List<Map<String, dynamic>>? _profileToolsMap;
  bool _isLoading = true;
  String? _error;

  List<Tool>? get diary => _diary;
  List<Map<String, dynamic>>? get profileToolsMap => _profileToolsMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isToolInDiary(Tool tool) {
    if (_diary == null) return false;
    return _diary!.any((t) => t.id == tool.id);
  }

  bool isToolAFavorite(Tool tool) {
    if (_profileToolsMap == null) return false;
    final match = _profileToolsMap!.firstWhere(
          (map) => map['tool_id'] == tool.id,
      orElse: () => {},
    );
    if (match.isEmpty) return false;
    return match['is_favorite'] == true;
  }


  Future<void> fetchDiary(String profileId) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      //fetch which tools are recommended for the user
      final toolsMap = await _client
          .from('profile_tools_map')
          .select('tool_id, is_favorite')
          .eq('profile_id', profileId);

      _profileToolsMap = List<Map<String, dynamic>>.from(toolsMap);
      final toolIds = _profileToolsMap!.map((e) => e['tool_id'] as int).toSet().toList();

      if (toolIds.isEmpty) {
        _diary = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      //fetch the tools data
      final toolsResponse = await _client.from('tools').select().inFilter('id', toolIds);

      final toolsList = List<Map<String, dynamic>>.from(toolsResponse);

      _diary = toolsList.map((map) => Tool.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToolToDiary({
    required String profileId,
    required Tool tool,
  }) async {
    print('aaaaaaaaa');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('qqqqqqqqqq');

      // Insert into Supabase
      await _client.from('profile_tools_map').insert({
        'profile_id': profileId,
        'tool_id': tool.id,
      });

      print('wwwwwwwww');

      // Update local state
      _profileToolsMap ??= [];
      _profileToolsMap!.add({
        'profile_id': profileId,
        'tool_id': tool.id,
      });

      _diary ??= [];
      _diary!.add(tool);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> deleteToolFromDiary({required String profileId, required int toolId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tools_map')
          .delete()
          .eq('profile_id', profileId)
          .eq('tool_id', toolId);

      // Remove from local state
      _profileToolsMap?.removeWhere((map) => map['tool_id'] == toolId);
      _diary?.removeWhere((tool) => tool.id == toolId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateFavoriteStatus({required String profileId, required int toolId, required bool isFavorite}) async {
    try {
      await _client
          .from('profile_tools_map')
          .update({'is_favorite': isFavorite})
          .eq('profile_id', profileId)
          .eq('tool_id', toolId);

      // Update local cache
      final map = _profileToolsMap?.firstWhere(
            (m) => m['tool_id'] == toolId,
        orElse: () => {},
      );

      if (map != null && map.isNotEmpty) {
        map['is_favorite'] = isFavorite;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}