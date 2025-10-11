import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/supabase_tables.dart';
import '../widgets/toast.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  User? _user;
  Profile? _profile;
  bool _isLoading = true;
  String? _error;
  String? _otpCode;
  DateTime? _otpExpiry;

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
      _client.auth.onAuthStateChange.listen((data) async {
        final newUser = data.session?.user;

        // Normal user session updates
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


      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: "myapp://login-callback/",
      );

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
      print('sign up error ${e.toString()}');
      if(e.toString().contains('user_already_exists')) {
        _error = 'User already exists';
        throw Exception('user_already_exists');
      } else if (e.toString().contains('weak_password')) {
        _error = 'Weak password';
        throw Exception('weak_password');
      }
      throw Exception('Something went wrong');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in
  Future<AuthResponse> signIn({required String email, required String password}) async {
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

      // 1. Insert into profile_professions_map
      final batchProfileProfessions = professions.map((prof) {
        return {
          'profile_id': _user!.id,
          'profession_id': prof['id'],
        };
      }).toList();

      await _client.from(SupabaseTables.profile_professions_map.name).insert(batchProfileProfessions);

      // 2. Fetch all relevant group_ids via group_profession_map
      final professionIds = professions.map((p) => p['id']).toList();

      final groupMap = await _client
          .from(SupabaseTables.group_profession_map.name)
          .select('group_id, profession_id')
          .inFilter('profession_id', professionIds);

      final groupIds = groupMap.map((e) => e['group_id'] as int).toSet().toList();

      // 3. Fetch all tools in these groups
      final tools = await _client
          .from(SupabaseTables.tools.name)
          .select('id, name, group_id')
          .inFilter('group_id', groupIds);

      // --- CURATION LOGIC ---
      // Step A: Organize tools by group
      final Map<int, List<Map<String, dynamic>>> toolsByGroup = {};
      for (var tool in tools) {
        final gid = tool['group_id'] as int;
        toolsByGroup.putIfAbsent(gid, () => []).add(tool);
      }

      // Step B: Decide cap based on profession count
      final int professionCount = professions.length;
      final int toolCap = professionCount == 1
          ? 4
          : professionCount == 2
          ? 7
          : 10;

      // Step C: Pick tools with group safeguard
      final List<Map<String, dynamic>> curatedTools = [];
      final groupList = toolsByGroup.entries.toList();

      if (groupList.length <= toolCap) {
        // Case 1: groups fit into cap → at least 1 per group
        for (var entry in groupList) {
          if (entry.value.isNotEmpty) {
            curatedTools.add(entry.value.first);
          }
        }

        // Fill remaining slots if space left
        int remaining = toolCap - curatedTools.length;
        while (remaining > 0) {
          bool addedAny = false;
          for (var entry in groupList) {
            if (remaining <= 0) break;

            final groupTools = entry.value;
            final alreadyPickedIds = curatedTools.map((t) => t['id']).toSet();

            final nextTool = groupTools.firstWhere(
                  (t) => !alreadyPickedIds.contains(t['id']),
              orElse: () => {},
            );

            if (nextTool.isNotEmpty) {
              curatedTools.add(nextTool);
              remaining--;
              addedAny = true;
            }
          }
          if (!addedAny) break; // nothing left to add
        }
      } else {
        // Case 2: too many groups → pick cap number of groups only
        groupList.shuffle(); // random for now (could be ranked later)
        for (var i = 0; i < toolCap; i++) {
          final groupTools = groupList[i].value;
          if (groupTools.isNotEmpty) {
            curatedTools.add(groupTools.first);
          }
        }
      }

      // --- Insert curated tools ---
      final batchProfileTools = curatedTools.map((tool) {
        return {
          'profile_id': _user!.id,
          'tool_id': tool['id'],
          'is_favorite': false,
        };
      }).toList();

      await _client.from(SupabaseTables.profile_tools_map.name).insert(batchProfileTools);

      // 4. Mark profile as onboarded
      final res = await _client
          .from(SupabaseTables.profiles.name)
          .update({'onboarded': true})
          .eq('id', _user!.id)
          .select();

      Map<String, dynamic> data = res[0];
      final newProfile = Profile.fromMap(data);
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


  Future<void> changeUsername({required String newUsername, required String password}) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Step 1: Verify password correctness
      final loginResponse = await _client.auth.signInWithPassword(
        email: _user!.email!,
        password: password,
      );

      // If no user returned, credentials are wrong
      if (loginResponse.user == null) {
        throw Exception('wrong-password');
      }

      // Step 2: Check if the username already exists
      final existing = await _client
          .from(SupabaseTables.profiles.name)
          .select('id')
          .eq('username', newUsername)
          .maybeSingle();

      if (existing != null) {
        throw Exception('username-exists');
      }

      // Step 3: Proceed with username update
      await _client
          .from(SupabaseTables.profiles.name)
          .update({'username': newUsername})
          .eq('id', _user!.id);

      // Step 4: Refresh user profile
      await refreshProfile();

    } catch (e) {
      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('wrong-password')) {
        _error = 'wrong-password';
        throw Exception('wrong-password');
      } else if (e.toString().contains('username-exists')) {
        _error = 'username-exists';
        throw Exception('username-exists');
      } else {
        _error = 'unknown-error';
        throw Exception('unknown-error');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Step 1: Verify current password
      final loginResponse = await _client.auth.signInWithPassword(
        email: _user!.email!,
        password: currentPassword,
      );

      if (loginResponse.user == null) {
        throw Exception('wrong-password');
      }

      // Step 2: Update password securely via Supabase Auth API
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('password-update-failed');
      }

      // Step 3: Log out user (must re-login with new password)
      await _client.auth.signOut();

    } catch (e) {
      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('wrong-password')) {
        _error = 'wrong-password';
        throw Exception('wrong-password');
      } else {
        _error = 'unknown-error';
        throw Exception('unknown-error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  
  Future<void> sendResetPasswordLinkToEmail(String email) async {
    try{
      await _client.auth.resetPasswordForEmail(email, redirectTo: 'myapp://password-reset-callback/',);
    } catch(e) {
      throw Exception('Something went wrong');
    }
  }

  Future<bool> resetPassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      notifyListeners();
      return response.user != null;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  bool verifyOtp(String code) {
    if (_otpCode == null) return false;
    if (_otpExpiry == null || DateTime.now().isAfter(_otpExpiry!)) {
      showToast('OTP expired. Please request a new code.');
      return false;
    }
    return code == _otpCode;
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit code
  }












  Future<bool> sendVerificationCode(String email) async {
    try {
      _otpCode = _generateOtp();
      _otpExpiry = DateTime.now().add(const Duration(minutes: 10));

      // Optional: log for dev
      print('Generated OTP for $email: $_otpCode');

      // Trigger Edge Function to send mail
      final response = await _client.functions.invoke(
        'send_verification_otp', // you can rename to send_verification_otp if you prefer
        body: {'email': email, 'otp': _otpCode},
      );

      if (response.status != 200) {
        print('Error sending verification code: ${response.data}');
        showToast('Failed to send email. Try again.');
        return false;
      }

      showToast('Verification code sent to $email');
      return true;
    } catch (e) {
      print('sendVerificationCode error: $e');
      showToast('Something went wrong.');
      return false;
    }
  }

  Future<void> verifyEmailByCode(String code) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool ok = verifyOtp(code);

      if (ok) {
        await _client
            .from(SupabaseTables.profiles.name)
            .update({'verified': true})
            .eq('id', _user!.id);

        await refreshProfile();
        showToast('Email verified successfully!');
      } else {
        showToast('Invalid OTP code.');
      }

    } catch (e) {
      print('verifyEmailByCode error: $e');
      _error = e.toString();
    } finally {
      _otpCode = null;
      _otpExpiry = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
