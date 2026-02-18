import 'package:flutter/material.dart';
import 'edit_task_page.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewTaskPage extends StatelessWidget {
  final Map task;
  const ViewTaskPage({super.key, required this.task});

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
      "Dec",
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
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

  Widget chip({required Widget child, required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (task["title"] ?? "").toString();
    final desc = (task["description"] ?? "").toString();

    final pr = (task["priority"] ?? "medium").toString();
    final due = task["due_date"];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FF),
        elevation: 0,
        title: const Text(
          "Task",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: const Color(0xFF1A73E8),
            tooltip: "Edit",
            onPressed: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTaskPage(task: task)),
              );

              if (refresh == true) {
                Navigator.pop(context, true);
              }
            },
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
              // CHIPS ROW
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  chip(
                    bg: priorityColor(pr).withOpacity(0.12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: priorityColor(pr),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Priority: ${priorityLabel(pr)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: priorityColor(pr),
                          ),
                        ),
                      ],
                    ),
                  ),
                  chip(
                    bg: Colors.black.withOpacity(0.06),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          due == null ? "No due date" : formatDueDate(due),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // TITLE
              Text(
                title.isEmpty ? "Untitled" : title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 14),

              // DESCRIPTION
              Expanded(
                child: SingleChildScrollView(
                  child: Linkify(
                    text: desc.isEmpty
                        ? "No description added.\n\nTap Edit to add notes."
                        : desc,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: desc.isEmpty ? Colors.grey[600] : Colors.black87,
                    ),
                    linkStyle: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w600,
                    ),
                    onOpen: (link) async {
                      final url = Uri.parse(link.url);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
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
