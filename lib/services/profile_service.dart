import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  ///profiles table
  //READS
  Future<Profile?> getProfileById(String id) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      print(' ✔ DB READ: profile by id');

      if (data == null) return null;
      return Profile.fromMap(data);

    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfileByEmail(String email) async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('email', email)
        .maybeSingle();

    print(' ✔ DB READ: profile by email');

    return res;
  }

  Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();

    print(' ✔ DB READ: profile by username');

    return res;
  }


  //WRITES
  Future<void> createProfile({required String id, required String email, required String username, required bool verified}) async {

    try{
      await _client.from('profiles').insert({
        'id': id,
        'email': email,
        'username': username,
        'verified': verified,
        'onboarded': false
      });

      print(' ✔ DB WRITE: new profile created');

    } catch (e) {
      print(' ❌ Error creating profile: $e');
      throw Exception('Error creating profile: $e');
    }
  }


  ///professions table
  //READS
  Future<List<Map<String, dynamic>>> fetchProfessions() async {
    try {
      final data = await _client
          .from('professions')
          .select();

      print('✔ DB READ: fetched ${data.length} professions');

      // Supabase always returns List<dynamic>, so cast it to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data);

    } catch (e) {
      print('❌ Error fetching professions: $e');
      return [];
    }
  }


  ///profile_professions table
  //WRITES
  Future<void> createProfileProfessions(List<String> professions) async{
    try{

    } catch (e) {

    }
  }
}
