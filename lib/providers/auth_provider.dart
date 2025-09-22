import 'package:flutter/material.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  User? _user;
  Profile? _profile;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider(){_init();}

  Future<void> _init() async {
    try {
      final session = _client.auth.currentSession;
      _user = session?.user;

      print('0');

      // Only fetch if user exists AND profile not yet loaded
      if (_user != null && _profile == null) {
        _profile = await _profileService.getProfileById(_user!.id);
        print('1');
      }

      // Listen for future auth state changes
      _client.auth.onAuthStateChange.listen((event) async {
        final newUser = event.session?.user;
        if (newUser?.id != _user?.id) {
          _user = newUser;

          if (_user != null) {
            _profile = await _profileService.getProfileById(_user!.id);
            print('2');
          } else {
            _profile = null;
          }

          notifyListeners();
        }
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Sign up
  Future<AuthResponse> signUpWithEmailPassword({required String email, required String password, required String username,}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('aaaaaaaaa');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: "myapp://login-callback/",
      );
      print('aaaaaaaaaaaa');

      print('📩 AuthResponse: $response');
      print('👤 response.user: ${response.user}');
      print('🔑 response.session: ${response.session}');

      _user = response.user;

      print('returned user $_user');

      if (_user != null) {
        await _profileService.createProfile(
          id: _user!.id,
          email: email,
          username: username,
          verified: false,
        );

        await Future.delayed(Duration(seconds: 2));

        _profile = await _profileService.getProfileById(_user!.id);
        notifyListeners();
      }

      return response;

    } catch (e) {
      _error = e.toString();
      throw Exception('❌ Provider sign up exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in
  Future<AuthResponse> signIn({required String email, required String password,}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _user = response.user;
      print(response);
      print(_user);

      if (_user != null) {
        _profile = await _profileService.getProfileById(_user!.id);
        notifyListeners();
      }

      return response;
    } catch (e) {
      _error = e.toString();
      throw Exception('❌ Provider sign in exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    if (_user == null) return; // nothing to refresh

    try {
      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.getProfileById(_user!.id);

    } catch (e) {
      _error = e.toString();
      print('refresh profile failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Onboard user
  Future<void> onboard(List<Map<String, dynamic>> professions) async {

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Insert into profile_professions
      final batchProfileProfessions = professions.map((prof) {
        return {
          'profile_id': _user!.id,
          'profession_id': prof['id'], // Make sure this is the profession id
        };
      }).toList();

      await _client.from('profile_professions_map').insert(batchProfileProfessions);


      // 2 Fetch all relevant group_ids via group_profession_map
      final professionIds = professions.map((p) => p['id']).toList();


      final groupMap = await _client
          .from('group_profession_map')
          .select('group_id, profession_id')
          .inFilter('profession_id', professionIds);


      final groupIds = groupMap.map((e) => e['group_id'] as int).toSet().toList();


      // 3 Fetch all tools in these groups
      final tools = await _client
          .from('tools')
          .select('id, name, group_id')
          .inFilter('group_id', groupIds);


      // 4 Insert into profile_tools
      final batchProfileTools = tools.map((tool) {
        return {
          'profile_id': _user!.id,
          'tool_id': tool['id'],
          'is_favorite': false, // default value
        };
      }).toList();


      await _client.from('profile_tools_map').insert(batchProfileTools);

      final res = await _client.from('profiles')
                              .update({'onboarded': true})
                              .eq('id', _user!.id)
                              .select();


      Map<String, dynamic> data = res[0];
      print(data);
      final newProfile = Profile.fromMap(data);
      print(newProfile);
      _profile = newProfile;
      notifyListeners();

      print('✅ Onboarding complete with curated tools');

    } catch (e) {
      print('❌ Error during onboarding: $e');
      throw Exception('Error updating professions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
