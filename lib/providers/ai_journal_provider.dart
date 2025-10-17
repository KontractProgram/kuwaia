import 'package:flutter/material.dart';
import 'package:kuwaia/models/community/latest.dart';
import 'package:kuwaia/models/community/promotion.dart';
import 'package:kuwaia/models/in_tool/prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community/freelancer.dart';
import '../models/community/news.dart';
import '../models/tool.dart';
import '../services/profile_service.dart';
import '../services/supabase_tables.dart';

class AiJournalProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;
  final _profileId = Supabase.instance.client.auth.currentUser!.id;

  List<Tool>? _trendingTools;
  List<Latest>? _latestList;
  List<News>? _newsList;

  List<Prompt>? _journalPrompts;
  Map<int, String>? _promptOwnersMap;
  final Map<int, int> _promptLikesCount = {};
  final Set<int> _likedPrompts = {};

  List<Freelancer>? _freelancers;
  List<String>? _freelancerUrls;
  List<Promotion>? _promotions;

  bool _isLoading = true;
  String? _error;

  List<Tool>? get trendingTools => _trendingTools;
  List<Latest>? get latestList => _latestList;
  List<News>? get newsList => _newsList;

  List<Prompt>? get journalPrompts => _journalPrompts;
  Map<int, String>? get promptOwnersMap => _promptOwnersMap;
  int getLikes(int promptId) => _promptLikesCount[promptId] ?? 0;
  bool userLikesPrompt(int promptId) => _likedPrompts.contains(promptId);

  List<Freelancer>? get freelancers => _freelancers;
  List<String>? get freelancerUrls => _freelancerUrls;
  List<Promotion>? get promotions => _promotions;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String getOwnerByPromptId(int promptId) {
    if (_promptOwnersMap == null || _promptOwnersMap!.isEmpty) {
      return 'Unknown';
    }
    // If the map contains the prompt ID, return the username
    return _promptOwnersMap![promptId] ?? 'Unknown';
  }


  Future<Tool?> fetchToolById(int toolId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final toolsResponse = await _client.from(SupabaseTables.tools.name).select().eq('id', toolId).maybeSingle();

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

      final trendingResponse = await _client.from(SupabaseTables.trending.name).select();

      final trendingList = List<Map<String, dynamic>>.from(trendingResponse);

      final toolIds = trendingList.map((map) => map['tool_id'] as int).toList();

      if (toolIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final toolsResponse = await _client
          .from(SupabaseTables.tools.name)
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

      final latestResponse = await _client.from(SupabaseTables.latest.name).select();

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

      final newsResponse = await _client.from(SupabaseTables.news.name).select();

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

      final journalPromptsResponse = await _client.from(SupabaseTables.profile_tool_prompts.name).select().isFilter('in_journal', true);

      final journalPromptsResponseList = List<Map<String, dynamic>>.from(journalPromptsResponse);

      _journalPrompts = journalPromptsResponseList.map((map) => Prompt.fromMap(map)).toList();

      // 🧩 Initialize owners map
      _promptOwnersMap = {};

      // 🧑‍💻 Fetch all owners (in parallel)
      final profileService = ProfileService();
      final futures = _journalPrompts!.map((prompt) async {
        final ownerId = prompt.ownerId;
        final profile = await profileService.getProfileById(ownerId);
        if (profile != null) {
          _promptOwnersMap![prompt.id] = profile.username;
        }
      }).toList();

      // Wait for all profile fetches
      await Future.wait(futures);

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePrompt({required int promptId}) async {
    _likedPrompts.add(promptId);
    _promptLikesCount[promptId] = (_promptLikesCount[promptId] ?? 0) + 1;
    notifyListeners();

    try {
      await _client.from(SupabaseTables.prompts_likes.name).insert({
        'profile_id': _profileId,
        'prompt_id': promptId,
      });
    } catch (e) {
      // revert optimistic update
      _likedPrompts.remove(promptId);
      _promptLikesCount[promptId] = (_promptLikesCount[promptId]! - 1).clamp(0, double.infinity).toInt();
    } finally {notifyListeners();}
  }

  Future<void> unlikePrompt({required int promptId}) async {
    _likedPrompts.remove(promptId);
    _promptLikesCount[promptId] = (_promptLikesCount[promptId]! - 1).clamp(0, double.infinity).toInt();
    notifyListeners();

    try {
      await _client
          .from(SupabaseTables.prompts_likes.name)
          .delete()
          .match({'profile_id': _profileId, 'prompt_id': promptId});
    } catch (e) {
      _error = e.toString();
      // revert optimistic update
      _likedPrompts.add(promptId);
      _promptLikesCount[promptId] = (_promptLikesCount[promptId] ?? 0) + 1;
      notifyListeners();
    } finally {notifyListeners();}
  }

  Future<void> loadPromptLikes(int promptId) async {
    try {
      // total likes
      final response = await _client
          .from(SupabaseTables.prompts_likes.name)
          .select('prompt_id')
          .eq('prompt_id', promptId)
          .count(CountOption.exact);

      _promptLikesCount[promptId] = response.count ?? 0;

      // check if current user liked
      final liked = await _client
          .from(SupabaseTables.prompts_likes.name)
          .select('prompt_id')
          .match({'prompt_id': promptId, 'profile_id': _profileId})
          .maybeSingle();

      if (liked != null) _likedPrompts.add(promptId);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }


  ///FREELANCERS
  Future<void> fetchFreelancers() async{
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      //fetch freelancers
      final freelancersResponse = await _client.from(SupabaseTables.freelancers.name).select();

      final freelancersResponseList = List<Map<String, dynamic>>.from(freelancersResponse);

      _freelancers = freelancersResponseList.map((map) => Freelancer.fromMap(map)).toList();

      //fetch promotions
      final promotionsResponse = await _client.from(SupabaseTables.freelancer_promotions.name).select();

      final promotionsResponseList = List<Map<String, dynamic>>.from(promotionsResponse);

      _promotions = promotionsResponseList.map((map) => Promotion.fromMap(map)).toList();

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

      final freelancerImageUrlResponse = await _client.from(SupabaseTables.freelancer_gallery.name).select().eq('freelancer_id', id);

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

  Future<void> fetchFreelancerPromotions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final promotionsResponse = await _client.from(SupabaseTables.freelancer_promotions.name).select();

      final promotionsResponseList = List<Map<String, dynamic>>.from(promotionsResponse);

      _promotions = promotionsResponseList.map((map) => Promotion.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendFreelancerRequest(String email) async {
    try {
      print(email);
      await _client.from(SupabaseTables.freelancer_requests.name).insert({'email': email});
      return true;
    } catch(e) {
      print('request error ${e.toString()}');
     return false;
    }
  }


}