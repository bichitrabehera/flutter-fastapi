import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'add_task_page.dart';
import 'view_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.getTasks();
      if (!mounted) return;
      setState(() {
        tasks = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // Priority dot color
  Color priorityColor(String value) {
    if (value == "high") return Colors.red;
    if (value == "low") return Colors.green;
    return Colors.orange;
  }

  // Due date text
  String formatDueDate(dynamic raw) {
    if (raw == null) return "";
    final d = DateTime.parse(raw).toLocal();
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${d.day} ${months[d.month - 1]}";
  }

  void logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // OPEN ADD PAGE
  Future<void> openAddPage() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskPage()),
    );

    if (refresh == true) {
      loadTasks();
    }
  }

  // OPEN VIEW PAGE
  Future<void> openViewPage(Map task) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewTaskPage(task: task)),
    );

    if (refresh == true) {
      loadTasks();
    }
  }

  // TOGGLE COMPLETED
  Future<void> toggleCompleted(Map task) async {
    final bool current = task["completed"] ?? false;

    setState(() {
      task["completed"] = !current;
    });

    try {
      await ApiService.toggleTaskCompletion(task["id"].toString(), !current);
    } catch (_) {
      setState(() {
        task["completed"] = current;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FF),
        elevation: 0,
        title: const Text(
          "My Tasks",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            color: Colors.black87,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "No tasks yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap + to create your first task",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[300]),
                  itemBuilder: (_, i) {
                    final task = tasks[i];
                    final bool completed = task["completed"] ?? false;

                    final String pr =
                        (task["priority"] ?? "medium").toString();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      leading: Checkbox(
                        value: completed,
                        onChanged: (_) => toggleCompleted(task),
                      ),

                      // UPDATED TITLE ROW
                      title: Row(
                        children: [
                          // Priority dot
                          Container(
                            height: 9,
                            width: 9,
                            decoration: BoxDecoration(
                              color: priorityColor(pr),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Title
                          Expanded(
                            child: Text(
                              task["title"] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: completed
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),

                          // Due date chip
                          if (task["due_date"] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                formatDueDate(task["due_date"]),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                        ],
                      ),

                      subtitle: task["description"]?.isNotEmpty == true
                          ? Text(
                              task["description"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: completed
                                    ? Colors.grey[500]
                                    : Colors.grey[700],
                              ),
                            )
                          : null,
                      trailing:
                          Icon(Icons.chevron_right, color: Colors.grey[500]),
                      onTap: () => openViewPage(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddPage,
        backgroundColor: const Color(0xFF1A73E8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
