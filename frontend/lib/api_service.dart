import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final _supabase = Supabase.instance.client;

  // GET /tasks
  static Future<List<dynamic>> getTasks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response as List<dynamic>;
  }

  // POST /tasks
  static Future<void> createTask(String title, String description) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'user_id': userId,
      'completed': false,
    });
  }

  // PUT /tasks/{id}
  static Future<void> updateTask(
    String id,
    String title,
    String description,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase.from('tasks').update({
      'title': title,
      'description': description,
    }).match({'id': id, 'user_id': userId});
  }

  // DELETE /tasks/{id}
  static Future<void> deleteTask(dynamic id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _supabase
        .from('tasks')
        .delete()
        .match({'id': id, 'user_id': userId});
  }
}