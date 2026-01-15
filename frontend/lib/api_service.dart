import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, String>> _authHeader() async {
  final session = Supabase.instance.client.auth.currentSession;
  final token = session?.accessToken;

  print("TOKEN => $token"); // 👈 DEBUG

  if (token == null) {
    throw Exception("User not authenticated");
  }

  return {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };
}


  // GET /tasks
  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"]; // ✅ FIX
    }
    throw Exception(response.body);
  }

  // POST /tasks
  static Future<void> createTask(String title, String description) async {
    final response = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: await _authHeader(),
      body: jsonEncode({
        "title": title,
        "description": description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // PUT /tasks/{id}
  static Future<void> updateTask(String id, String title, String description) async {
    final response = await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: await _authHeader(),
      body: jsonEncode({
        "title": title,
        "description": description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // DELETE /tasks/{id}
  static Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: await _authHeader(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
