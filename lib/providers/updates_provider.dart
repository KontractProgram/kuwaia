import 'package:flutter/material.dart';
import 'package:kuwaia/services/supabase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/update_model.dart';

class UpdatesProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final List<UpdateModel> _updates = [];

  static const int _youtubePageSize = 5;
  int _youtubeFetchedCount = 0;
  int _nonYoutubeFetchedCount = 0;

  bool _isLoading = false;
  bool _hasMore = true;

  List<UpdateModel> get updates => _updates;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;


  void _resetState() {
    _updates.clear();
    _youtubeFetchedCount = 0;
    _nonYoutubeFetchedCount = 0;
    _hasMore = true;
  }



  Future<void> fetchUpdates({bool loadMore = false}) async {
    if (_isLoading || !_hasMore) return;

    if (!loadMore) {
      _resetState();
    }

    _isLoading = true;
    notifyListeners();

    try {
      print(111111111111111);
      // --- A. Fetch a chunk of YOUTUBE Shorts (PRIMARY content) ---
      final youtubeResponse = await _client
          .from(SupabaseTables.updates.name)
          .select()
          .eq('is_youtube_link', true) // Filter: ONLY Shorts
          .order('created_at', ascending: false)
          .range(_youtubeFetchedCount, _youtubeFetchedCount + _youtubePageSize - 1);

      print(2222222222222222);

      final List<UpdateModel> fetchedYoutube = youtubeResponse
          .map((e) => UpdateModel.fromJson(e))
          .toList();

      print(3333333333333);

      // Check if we ran out of YouTube Shorts
      if (fetchedYoutube.isEmpty && _youtubeFetchedCount > 0) {
        _hasMore = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      print(44444444444444);

      // --- B. Fetch ONE NON-YOUTUBE item (The strategic injection) ---
      // We fetch one item at a time, using a separate counter for its offset.
      final nonYoutubeResponse = await _client
          .from(SupabaseTables.updates.name)
          .select()
          .eq('is_youtube_link', false) // Filter: ONLY non-Shorts
          .order('created_at', ascending: false)
          .range(_nonYoutubeFetchedCount, _nonYoutubeFetchedCount); // Fetch only 1

      final List<UpdateModel> fetchedNonYoutube = nonYoutubeResponse
          .map((e) => UpdateModel.fromJson(e))
          .toList();

      // --- C. Merge and Update List ---

      List<UpdateModel> combined = [];

      // Add the YouTube Shorts chunk
      combined.addAll(fetchedYoutube);

      // Insert the non-YouTube item at a strategic point (e.g., after the 3rd short)
      if (fetchedNonYoutube.isNotEmpty) {
        // Calculate the insertion index.
        // Use the min to ensure we don't go out of bounds if less than 5 shorts were fetched.
        int insertionIndex = (_youtubePageSize ~/ 2); // Inserts after item 2 or 3

        if (combined.isNotEmpty) {
          combined.insert(insertionIndex.clamp(0, combined.length), fetchedNonYoutube.first);
        } else {
          // If somehow no shorts were fetched but an ad was, add the ad.
          combined.add(fetchedNonYoutube.first);
        }
      }

      // Add combined chunk to the main list
      _updates.addAll(combined);

      // --- D. Update Counters ---

      // Always update the primary content counter by the number of items successfully fetched
      _youtubeFetchedCount += fetchedYoutube.length;

      // Update the injection content counter ONLY if we successfully fetched one
      if (fetchedNonYoutube.isNotEmpty) {
        _nonYoutubeFetchedCount += 1;
      }

      // If we fetched fewer YouTube items than the page size, we're at the end of the primary content.
      if (fetchedYoutube.length < _youtubePageSize) {
        _hasMore = false;
      }

    } catch (e) {
      debugPrint('Error fetching shorts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
