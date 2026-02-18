import 'package:flutter/material.dart';
import 'api_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool saving = false;

  // NEW
  String priority = "medium"; // low / medium / high
  DateTime? dueDate;

  Future<void> saveTask() async {
    if (titleCtrl.text.trim().isEmpty) return;

    setState(() => saving = true);

    await ApiService.createTask(
      titleCtrl.text.trim(),
      descCtrl.text.trim(),
      priority: priority,
      dueDate: dueDate,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;

    setState(() {
      // keep only date (00:00 time)
      dueDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  String formatDueDate(DateTime date) {
    // simple format: 18 Feb 2026
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  InputDecoration flatInput(String hint) {
    return InputDecoration(
      hintText: hint,
      border: InputBorder.none,
    );
  }

  Color priorityColor(String value) {
    if (value == "high") return Colors.red;
    if (value == "low") return Colors.green;
    return Colors.orange;
  }

  String priorityLabel(String value) {
    if (value == "high") return "High";
    if (value == "low") return "Low";
    return "Medium";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FF),
        elevation: 0,
        title: const Text("Add Task", style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: saving ? null : saveTask,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: titleCtrl,
                decoration: flatInput("Title"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              // Priority + Due Date row
              Row(
                children: [
                  // Priority dropdown
                  DropdownButton<String>(
                    value: priority,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: "low", child: Text("Low")),
                      DropdownMenuItem(value: "medium", child: Text("Medium")),
                      DropdownMenuItem(value: "high", child: Text("High")),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => priority = value);
                    },
                  ),

                  const SizedBox(width: 12),

                  // priority dot
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: priorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const Spacer(),

                  // Due date picker
                  TextButton.icon(
                    onPressed: pickDueDate,
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      dueDate == null ? "Add due date" : formatDueDate(dueDate!),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1A73E8),
                    ),
                  ),

                  if (dueDate != null)
                    IconButton(
                      tooltip: "Remove due date",
                      onPressed: () => setState(() => dueDate = null),
                      icon: const Icon(Icons.close, size: 18),
                      color: Colors.grey[600],
                    ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(color: Colors.grey[300]),

              const SizedBox(height: 10),

              // Description
              Expanded(
                child: TextField(
                  controller: descCtrl,
                  decoration: flatInput("Write something"),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
