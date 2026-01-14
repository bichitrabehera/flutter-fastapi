import 'package:flutter/material.dart';
import 'api_service.dart';

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

  /// ---------------- ADD TASK ----------------
  void openAddTaskSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Task", style: TextStyle(fontSize: 18)),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty) return;
                  await ApiService.createTask(
                    titleCtrl.text,
                    descCtrl.text,
                  );
                  Navigator.pop(context);
                  loadTasks();
                },
                child: const Text("Add"),
              )
            ],
          ),
        );
      },
    );
  }

  /// ---------------- VIEW / UPDATE / DELETE ----------------
  void openTaskDetails(Map task) {
    final titleCtrl = TextEditingController(text: task["title"]);
    final descCtrl = TextEditingController(text: task["description"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Task Details", style: TextStyle(fontSize: 18)),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ApiService.updateTask(
                          task["id"],
                          titleCtrl.text,
                          descCtrl.text,
                        );
                        Navigator.pop(context);
                        loadTasks();
                      },
                      child: const Text("Save"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await ApiService.deleteTask(task["id"]);
                        Navigator.pop(context);
                        loadTasks();
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks yet"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, i) {
                    final task = tasks[i];
                    return ListTile(
                      title: Text(task["title"] ?? ""),
                      subtitle: Text(
                        task["description"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => openTaskDetails(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
