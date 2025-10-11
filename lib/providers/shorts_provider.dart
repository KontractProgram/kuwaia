import 'package:flutter/material.dart';
import 'package:kuwaia/services/supabase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/short.dart';

class ShortsProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final List<Short> _shorts = [];

  bool _isLoading = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  List<Short> get shorts => _shorts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  ShortsProvider() {fetchShorts();}

  Future<void> fetchShorts({bool loadMore = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final from = loadMore ? _shorts.length : 0;
      final to = from + _pageSize - 1;

      final response = await _client
          .from(SupabaseTables.shorts.name)
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      print(response);

      if (response.isEmpty) {
        _hasMore = false;
      } else {
        final fetched = response.map((e) => Short.fromJson(e)).toList();

        if (loadMore) {
          _shorts.addAll(fetched);
        } else {
          _shorts
            ..clear()
            ..addAll(fetched);
        }
      }
    } catch (e) {
      debugPrint('Error fetching shorts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
