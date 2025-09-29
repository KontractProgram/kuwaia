import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tool.dart';

class AiJournalProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _trendingTools;


  bool _isLoading = true;
  String? _error;

  List<Tool>? get trendingTools => _trendingTools;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrendingTools({required String profileId}) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final trendingResponse = await _client.from('trending_tools').select();

      final trendingList = List<Map<String, dynamic>>.from(trendingResponse);

      _trendingTools = trendingList.map((map) => Tool.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}