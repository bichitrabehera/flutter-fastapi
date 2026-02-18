import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final _supabase = Supabase.instance.client;

  static String _getUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");
    return userId;
  }

  // -------------------------
  // GET tasks (all)
  // -------------------------
  static Future<List<dynamic>> getTasks() async {
    final userId = _getUserId();

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response as List<dynamic>;
  }

  // -------------------------
  // GET tasks (pending only)
  // -------------------------
  static Future<List<dynamic>> getPendingTasks({
    String sortBy = "created_at",
    bool ascending = false,
  }) async {
    final userId = _getUserId();

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('completed', false)
        .order(sortBy, ascending: ascending);

    return response as List<dynamic>;
  }

  // -------------------------
  // GET tasks (completed only)
  // -------------------------
  static Future<List<dynamic>> getCompletedTasks({
    String sortBy = "created_at",
    bool ascending = false,
  }) async {
    final userId = _getUserId();

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('completed', true)
        .order(sortBy, ascending: ascending);

    return response as List<dynamic>;
  }

  // -------------------------
  // Search tasks (title)
  // -------------------------
  static Future<List<dynamic>> searchTasks(
    String query, {
    bool? completed, // null = all, true = completed, false = pending
  }) async {
    final userId = _getUserId();

    var q = _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .ilike('title', '%$query%');

    if (completed != null) {
      q = q.eq('completed', completed);
    }

    final response = await q.order('created_at', ascending: false);

    return response as List<dynamic>;
  }

  // -------------------------
  // Create task (priority + due date)
  // -------------------------
  static Future<void> createTask(
    String title,
    String description, {
    String priority = "medium", // low / medium / high
    DateTime? dueDate,
  }) async {
    final userId = _getUserId();

    await _supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'user_id': userId,
      'completed': false,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    });
  }

  // -------------------------
  // Update task (priority + due date)
  // -------------------------
  static Future<void> updateTask(
    String id,
    String title,
    String description, {
    String? priority,
    DateTime? dueDate,
  }) async {
    final userId = _getUserId();

    await _supabase.from('tasks').update({
      'title': title,
      'description': description,
      if (priority != null) 'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    }).match({'id': id, 'user_id': userId});
  }

  // -------------------------
  // Toggle completed
  // -------------------------
  static Future<void> toggleTaskCompletion(String id, bool completed) async {
    final userId = _getUserId();

    await _supabase.from('tasks').update({
      'completed': completed,
    }).match({'id': id, 'user_id': userId});
  }

  // -------------------------
  // Delete task
  // -------------------------
  static Future<void> deleteTask(String id) async {
    final userId = _getUserId();

    await _supabase.from('tasks').delete().match({
      'id': id,
      'user_id': userId,
    });
  }
}
