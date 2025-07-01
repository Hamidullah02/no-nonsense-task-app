import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noslack/models/taskmodel.dart';
import 'package:noslack/widgets/home_widget/tag_btns.dart';

class editTaskWidget extends ConsumerStatefulWidget {
  final Task task;
  final index;

  editTaskWidget(this.task, this.index, {super.key});

  @override
  ConsumerState<editTaskWidget> createState() => _editTaskWidgetState();
}

class _editTaskWidgetState extends ConsumerState<editTaskWidget> {
  final titlecontroller = TextEditingController();
  final tagController = TextEditingController();
  final dueDateContoller = TextEditingController();
  final noteContoller = TextEditingController();

  @override
  void initState() {
    titlecontroller.text = widget.task.title;
    tagController.text = widget.task.tags;
    dueDateContoller.text = widget.task.dueDate!;
    noteContoller.text = widget.task.note ?? '';
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task.tags.isNotEmpty &&
          tagColors.containsKey(widget.task.tags)) {
        ref.read(selectedtagProvider.notifier).state = widget.task.tags;
      }
    });
  }

  @override
  void dispose() {
    titlecontroller.dispose();
    tagController.dispose();
    dueDateContoller.dispose();
    noteContoller.dispose();
    super.dispose();
  }

  void _resetTagSelection() {
    ref.read(selectedtagProvider.notifier).state = null;
  }

  void _closeDialog({bool taskSaved = false}) {
    if (!taskSaved) {
      _resetTagSelection();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _resetTagSelection();
        }
      },
      child: AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                _buildEditField("title", titlecontroller),
                const SizedBox(height: 12),
                TagSelector(controller: tagController, label: "Select Tag:"),
                const SizedBox(height: 12),
                _buildEditField("tag", tagController),
                const SizedBox(height: 12),
                TextField(
                  controller: dueDateContoller,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Due Date",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickDate != null) {
                      dueDateContoller.text =
                          pickDate.toIso8601String().split("T")[0];
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildEditField("add note", noteContoller),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cencel"),
          ),
          ElevatedButton(
            onPressed: () {
              final task = Task(
                title: titlecontroller.text.trim(),
                tags: tagController.text.trim(),
                dueDate: dueDateContoller.text.trim(),
                note: noteContoller.text.trim(),
              );
              ref.read(taskListProvider.notifier).editTask(task, widget.index);
              Navigator.of(context).pop();
            },
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

Widget _buildEditField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A40),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
