import 'package:flutter/material.dart';
import 'package:kuwaia/models/community/journal_video.dart';
import 'package:kuwaia/models/community/latest.dart';
import 'package:kuwaia/models/in_tool/prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community/news.dart';
import '../models/tool.dart';

class AiJournalProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _trendingTools;
  List<Latest>? _latestList;
  List<News>? _newsList;
  List<JournalVideo>? _journalVideos;
  List<Prompt>? _journalPrompts;

  bool _isLoading = true;
  String? _error;

  List<Tool>? get trendingTools => _trendingTools;
  List<Latest>? get latestList => _latestList;
  List<News>? get newsList => _newsList;
  List<JournalVideo>? get journalVideos => _journalVideos;
  List<Prompt>? get journalPrompts => _journalPrompts;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrendingTools() async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final trendingResponse = await _client.from('trending').select();

      final trendingList = List<Map<String, dynamic>>.from(trendingResponse);

      final toolIds = trendingList.map((map) => map['tool_id'] as int).toList();

      if (toolIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final toolsResponse = await _client
          .from('tools')
          .select()
          .inFilter('id', toolIds);

      final toolsList = List<Map<String, dynamic>>.from(toolsResponse);

      final tools = toolsList.map((map) => Tool.fromMap(map)).toList();

      _trendingTools = tools;
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final latestResponse = await _client.from('latest').select();

      final latestResponseList = List<Map<String, dynamic>>.from(latestResponse);

      _latestList = latestResponseList.map((map) => Latest.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newsResponse = await _client.from('news').select();

      final newsResponseList = List<Map<String, dynamic>>.from(newsResponse);

      _newsList = newsResponseList.map((map) => News.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideosList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final videosResponse = await _client.from('videos').select();

      final videosResponseList = List<Map<String, dynamic>>.from(videosResponse);

      _journalVideos = videosResponseList.map((map) => JournalVideo.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJournalPrompts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final journalPromptsResponse = await _client.from('videos').select();

      final journalPromptsResponseList = List<Map<String, dynamic>>.from(journalPromptsResponse);

      _journalPrompts = journalPromptsResponseList.map((map) => Prompt.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


}