import 'package:flutter/cupertino.dart';
import 'package:kuwaia/models/in_tool/log_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/in_tool/Note.dart';
import '../models/in_tool/Video.dart';
import '../models/in_tool/prompt.dart';
import '../models/tool.dart';

class AiDiaryProvider with ChangeNotifier{
  final SupabaseClient _client = Supabase.instance.client;

  List<Tool>? _diary;
  List<Map<String, dynamic>>? _profileToolsMap;
  List<Prompt>? _myPrompts;
  List<Note>? _myNotes;
  List<Video>? _myVideos;
  LogDetails? _logDetails;
  bool _isLoading = true;
  String? _error;

  List<Tool>? get diary => _diary;
  List<Map<String, dynamic>>? get profileToolsMap => _profileToolsMap;
  List<Prompt>? get myPrompts => _myPrompts;
  List<Note>? get myNotes => _myNotes;
  List<Video>? get myVideos => _myVideos;
  LogDetails? get logDetails => _logDetails;
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

  Future<void> addToolToDiary({required String profileId, required Tool tool,}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Insert into Supabase
      await _client.from('profile_tools_map').insert({
        'profile_id': profileId,
        'tool_id': tool.id,
      });

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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFavoriteStatus({required String profileId, required int toolId, required bool isFavorite}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  //PROMPTS METHODS
  Future<void> fetchPrompts({required int toolId, required String profileId}) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'profile_id': profileId, 'tool_id': toolId};

      //fetch the prompts data
      final promptsResponse = await _client.from('profile_tool_prompts').select().match(query);

      final promptList = List<Map<String, dynamic>>.from(promptsResponse);

      _myPrompts = promptList.map((map) => Prompt.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPromptWithId({required int id, required int toolId, required String profileId}) async{
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'id': id, 'profile_id': profileId, 'tool_id': toolId};

      //fetch the prompts data
      final promptResponse = await _client.from('profile_tool_prompts').select().match(query);

      final promptMap = promptResponse[0];
      final prompt = Prompt.fromMap(promptMap);
      _myPrompts?.add(prompt);

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPrompt({required String description, required String prompt, required int toolId, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('profile_tool_prompts').insert({
        'description': description,
        'prompt': prompt,
        'tool_id': toolId,
        'profile_id': profileId
      });

      _myPrompts ??= [];
      fetchPrompts(toolId: toolId, profileId: profileId);

      _isLoading = false;
      notifyListeners();
    }  catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePrompt({required Prompt prompt, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_prompts')
          .update({'description': prompt.description, 'prompt': prompt.prompt})
          .eq('id', prompt.id)
          .eq('tool_id', prompt.toolId)
          .eq('profile_id', profileId);

      // Update local cache
      if (_myPrompts != null) {
        final index = _myPrompts!.indexWhere((p) => p.id == prompt.id);
        if (index != -1) {
          _myPrompts![index] = prompt;
        } else {
          // optional: insert if not found
          _myPrompts!.add(prompt);
        }
      } else {
        _myPrompts = [prompt];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePrompt({required Prompt prompt, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_prompts')
          .delete()
          .eq('id', prompt.id)
          .eq('profile_id', profileId)
          .eq('tool_id', prompt.toolId);

      // ✅ Remove from local state
      if (_myPrompts != null) {
        _myPrompts = _myPrompts!
            .where((p) => p.id != prompt.id)
            .toList();
      }

      _isLoading = false;
      notifyListeners();

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  //NOTES METHODS
  Future<void> fetchNotes({required int toolId, required String profileId}) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'profile_id': profileId, 'tool_id': toolId};

      //fetch the notes data
      final notesResponse = await _client.from('profile_tool_notes').select().match(query);

      final notesList = List<Map<String, dynamic>>.from(notesResponse);

      _myNotes = notesList.map((map) => Note.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNoteWithId({required int id, required int toolId, required String profileId}) async{
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'id': id, 'profile_id': profileId, 'tool_id': toolId};

      //fetch the notes data
      final notesResponse = await _client.from('profile_tool_notes').select().match(query);

      final notesMap = notesResponse[0];
      final note = Note.fromMap(notesMap);
      _myNotes?.add(note);

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote({required String note, required int toolId, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('profile_tool_notes').insert({
        'note': note,
        'tool_id': toolId,
        'profile_id': profileId
      });

      _myNotes ??= [];
      fetchNotes(toolId: toolId, profileId: profileId);

      _isLoading = false;
      notifyListeners();
    }  catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote({required Note note, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_notes')
          .update({'note': note.note})
          .eq('id', note.id)
          .eq('tool_id', note.toolId)
          .eq('profile_id', profileId);

      // Update local cache
      if (_myNotes != null) {
        final index = _myNotes!.indexWhere((p) => p.id == note.id);
        if (index != -1) {
          _myNotes![index] = note;
        } else {
          // optional: insert if not found
          _myNotes!.add(note);
        }
      } else {
        _myNotes = [note];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote({required Note note, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_notes')
          .delete()
          .eq('id', note.id)
          .eq('profile_id', profileId)
          .eq('tool_id', note.toolId);

      // ✅ Remove from local state
      if (_myNotes != null) {
        _myNotes = _myNotes!
            .where((n) => n.id != note.id)
            .toList();
      }

      _isLoading = false;
      notifyListeners();

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  //VIDEOS METHODS
  Future<void> fetchVideos({required int toolId, required String profileId}) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'profile_id': profileId, 'tool_id': toolId};

      //fetch the videos data
      final videosResponse = await _client.from('profile_tool_videos').select().match(query);

      final videosList = List<Map<String, dynamic>>.from(videosResponse);

      _myVideos = videosList.map((map) => Video.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideoWithId({required int id, required int toolId, required String profileId}) async{
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'id': id, 'profile_id': profileId, 'tool_id': toolId};

      //fetch the video data
      final videosResponse = await _client.from('profile_tool_videos').select().match(query);

      final videosMap = videosResponse[0];
      final video = Video.fromMap(videosMap);
      _myVideos?.add(video);

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVideo({required String videoLink, required int toolId, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('profile_tool_videos').insert({
        'video_link': videoLink,
        'tool_id': toolId,
        'profile_id': profileId
      });

      _myVideos ??= [];
      fetchVideos(toolId: toolId, profileId: profileId);

      _isLoading = false;
      notifyListeners();
    }  catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVideo({required Video video, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_videos')
          .update({'video_link': video.videoLink})
          .eq('id', video.id)
          .eq('tool_id', video.toolId)
          .eq('profile_id', profileId);

      // Update local cache
      if (_myVideos != null) {
        final index = _myVideos!.indexWhere((p) => p.id == video.id);
        if (index != -1) {
          _myVideos![index] = video;
        } else {
          // optional: insert if not found
          _myVideos!.add(video);
        }
      } else {
        _myVideos = [video];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVideo({required Video video, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_videos')
          .delete()
          .eq('id', video.id)
          .eq('profile_id', profileId)
          .eq('tool_id', video.toolId);

      // ✅ Remove from local state
      if (_myVideos != null) {
        _myVideos = _myVideos!
            .where((v) => v.id != video.id)
            .toList();
      }

      _isLoading = false;
      notifyListeners();

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  //LOG DETAILS METHODS
  Future<void> fetchLogDetails({required int toolId, required String profileId}) async {
    try{
      _isLoading = true;
      _error = null;
      notifyListeners();

      final query = {'profile_id': profileId, 'tool_id': toolId};

      //fetch the log details data
      final logDetailsResponse = await _client.from('profile_tool_log_details').select().match(query);

      if(logDetailsResponse.isNotEmpty){
        final logDetailsMap = logDetailsResponse[0];
        _logDetails = LogDetails.fromMap(logDetailsMap);
      }

      _isLoading = false;
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLogDetails({required String email, required String logPasswordHint, required int toolId, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('profile_tool_log_details').insert({
        'log_email': email,
        'log_password_hint': logPasswordHint,
        'tool_id': toolId,
        'profile_id': profileId
      });

      fetchLogDetails(toolId: toolId, profileId: profileId);

      _isLoading = false;
      notifyListeners();
    }  catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLogDetails({required LogDetails ld, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_log_details')
          .update({'log_email': ld.logEmail, 'log_password_hint': ld.logPasswordHint})
          .eq('id', ld.id)
          .eq('tool_id', ld.toolId)
          .eq('profile_id', profileId);

      // Update local cache
      if(_logDetails != null) {
        _logDetails = LogDetails(id: ld.id, logEmail: ld.logEmail, logPasswordHint: ld.logPasswordHint, toolId: ld.toolId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLogDetails({required LogDetails ld, required String profileId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('profile_tool_log_details')
          .delete()
          .eq('id', ld.id)
          .eq('profile_id', profileId)
          .eq('tool_id', ld.toolId);

      _logDetails = null;

      _isLoading = false;
      notifyListeners();

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


}