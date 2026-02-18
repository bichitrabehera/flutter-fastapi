import 'package:flutter/material.dart';
import 'api_service.dart';

class EditTaskPage extends StatefulWidget {
  final Map task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController titleCtrl;
  late final TextEditingController descCtrl;

  bool saving = false;
  bool deleting = false;

  late String priority;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.task["title"] ?? "");
    descCtrl = TextEditingController(text: widget.task["description"] ?? "");

    priority = (widget.task["priority"] ?? "medium").toString();

    if (widget.task["due_date"] != null) {
      final d = DateTime.parse(widget.task["due_date"]).toLocal();
      dueDate = DateTime(d.year, d.month, d.day);
    }
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

  String formatDueDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
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
      dueDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) return;

    setState(() => saving = true);

    await ApiService.updateTask(
      widget.task["id"].toString(),
      titleCtrl.text.trim(),
      descCtrl.text.trim(),
      priority: priority,
      dueDate: dueDate,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> deleteTask() async {
    setState(() => deleting = true);

    await ApiService.deleteTask(widget.task["id"].toString());

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Widget chip({
    required Widget child,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }

  Widget priorityChip(String value, String label) {
    final active = priority == value;

    return chip(
      bg: active
          ? priorityColor(value).withOpacity(0.18)
          : Colors.black.withOpacity(0.06),
      onTap: () => setState(() => priority = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: priorityColor(value),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? priorityColor(value) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FF),
        elevation: 0,
        title: const Text(
          "Edit Task",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: (saving || deleting) ? null : deleteTask,
            icon: deleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: "Delete",
          ),
          IconButton(
            onPressed: (saving || deleting) ? null : save,
            icon: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            color: const Color(0xFF1A73E8),
            tooltip: "Save",
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHIPS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  priorityChip("low", "Low"),
                  priorityChip("medium", "Medium"),
                  priorityChip("high", "High"),

                  chip(
                    bg: Colors.black.withOpacity(0.06),
                    onTap: pickDueDate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          dueDate == null
                              ? "Add due date"
                              : formatDueDate(dueDate!),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (dueDate != null)
                    chip(
                      bg: Colors.red.withOpacity(0.12),
                      onTap: () => setState(() => dueDate = null),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, size: 16, color: Colors.red),
                          SizedBox(width: 6),
                          Text(
                            "Remove",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // TITLE
              TextField(
                controller: titleCtrl,
                decoration: flatInput("Title"),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),

              // DESCRIPTION
              Expanded(
                child: TextField(
                  controller: descCtrl,
                  decoration: flatInput("Write something..."),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
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
