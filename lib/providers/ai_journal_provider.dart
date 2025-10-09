import 'package:flutter/material.dart';
import 'package:kuwaia/models/community/latest.dart';
import 'package:kuwaia/models/in_tool/prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community/freelancer.dart';
import '../models/community/news.dart';
import '../models/tool.dart';

class AiJournalProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _trendingTools;
  List<Latest>? _latestList;
  List<News>? _newsList;
  List<Prompt>? _journalPrompts;
  List<Freelancer>? _freelancers;
  List<String>? _freelancerUrls;

  bool _isLoading = true;
  String? _error;

  List<Tool>? get trendingTools => _trendingTools;
  List<Latest>? get latestList => _latestList;
  List<News>? get newsList => _newsList;
  List<Prompt>? get journalPrompts => _journalPrompts;
  List<Freelancer>? get freelancers => _freelancers;
  List<String>? get freelancerUrls => _freelancerUrls;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Tool?> fetchToolById(int toolId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final toolsResponse = await _client.from('tools').select().eq('id', toolId).maybeSingle();

      if(toolsResponse != null) {
        final tool = Tool.fromMap(toolsResponse);
        _isLoading = false;
        notifyListeners();
        return tool;
      }

      _isLoading = false;
      notifyListeners();
      return null;

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

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

  Future<void> fetchJournalPrompts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final journalPromptsResponse = await _client.from('profile_tool_prompts').select().isFilter('in_journal', true);

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


  ///FREELANCERS
  Future<void> fetchFreelancers() async{
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final freelancersResponse = await _client.from('freelancers').select();

      final freelancersResponseList = List<Map<String, dynamic>>.from(freelancersResponse);

      _freelancers = freelancersResponseList.map((map) => Freelancer.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGalleryByFreelancerId(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final freelancerImageUrlResponse = await _client.from('freelancer_gallery').select().eq('freelancer_id', id);

      if (freelancerImageUrlResponse.isNotEmpty) {
        _freelancerUrls = freelancerImageUrlResponse
            .map((row) {
          final url = row['image_url'];
          return (url is String) ? url : '';
        }).where((url) => url.isNotEmpty).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

}