import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noslack/models/taskmodel.dart';
import 'package:noslack/widgets/home_widget/tag_btns.dart';

class editTaskWidget extends ConsumerStatefulWidget {
  final Task task;
  final int index;

  const editTaskWidget(this.task, this.index, {super.key});

  @override
  ConsumerState<editTaskWidget> createState() => _editTaskWidgetState();
}

class _editTaskWidgetState extends ConsumerState<editTaskWidget> {
  final titlecontroller = TextEditingController();
  final tagController = TextEditingController();
  final dueDateContoller = TextEditingController();
  final noteContoller = TextEditingController();
  final focusTimeController = TextEditingController();

  @override
  void initState() {
    titlecontroller.text = widget.task.title;
    tagController.text = widget.task.tags;
    dueDateContoller.text = widget.task.dueDate ?? '';
    noteContoller.text = widget.task.note;
    focusTimeController.text = widget.task.focusTime;
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
    focusTimeController.dispose();
    super.dispose();
  }

  void _resetTagSelection() {
    ref.read(selectedtagProvider.notifier).state = null;
  }

  // Format time(e.g., "1h 30m")
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }

  Future<void> _showDurationPicker() async {
    int selectedHours = 0;
    int selectedMinutes = 30;

    if (focusTimeController.text.isNotEmpty) {
      final parts = focusTimeController.text.split(' ');
      for (String part in parts) {
        if (part.endsWith('h')) {
          selectedHours = int.tryParse(part.replaceAll('h', '')) ?? 0;
        } else if (part.endsWith('m')) {
          selectedMinutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text(
            'Set Focus Time',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hours picker
              Row(
                children: [
                  const Text(
                    'Hours: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: selectedHours.toDouble(),
                      min: 0,
                      max: 8,
                      divisions: 8,
                      activeColor: const Color(0xFF64D2FF),
                      label: selectedHours.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedHours = value.round();
                        });
                      },
                    ),
                  ),
                  Text(
                    '${selectedHours}h',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Minutes picker
              Row(
                children: [
                  const Text(
                    'Minutes: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: selectedMinutes.toDouble(),
                      min: 0,
                      max: 59,
                      divisions: 59,
                      activeColor: const Color(0xFF64D2FF),
                      label: selectedMinutes.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMinutes = value.round();
                        });
                      },
                    ),
                  ),
                  Text(
                    '${selectedMinutes}m',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Focus Time: ${_formatDuration(Duration(hours: selectedHours, minutes: selectedMinutes))}',
                  style: const TextStyle(
                    color: Color(0xFF64D2FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                focusTimeController.text = '';
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                final duration = Duration(
                  hours: selectedHours,
                  minutes: selectedMinutes,
                );
                focusTimeController.text = _formatDuration(duration);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D2FF),
              ),
              child: const Text(
                'Set',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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
        backgroundColor: const Color(0xFF1E1E2E),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                _buildEditField("Title", titlecontroller),
                const SizedBox(height: 12),
                TagSelector(controller: tagController, label: "Select Tag:"),
                const SizedBox(height: 12),

                // Date and Focus Time Row
                Row(
                  children: [
                    // Due Date Field
                    Expanded(
                      child: TextField(
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
                    ),
                    const SizedBox(width: 12),
                    // Focus Time Field
                    Expanded(
                      child: TextField(
                        controller: focusTimeController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Focus Time",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2A2A40),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(
                            Icons.timer,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: _showDurationPicker,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _buildEditField("Add note", noteContoller, maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _resetTagSelection();
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final task = Task(
                title: titlecontroller.text.trim(),
                tags: tagController.text.trim(),
                dueDate: dueDateContoller.text.trim(),
                focusTime: focusTimeController.text.trim(),
                note: noteContoller.text.trim(),
              );
              ref.read(taskListProvider.notifier).editTask(task, widget.index);
              _resetTagSelection();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64D2FF),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
}
