import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noslack/models/taskmodel.dart';
import 'package:noslack/widgets/home_widget/tag_btns.dart';

class AddTaskWidget extends ConsumerStatefulWidget {
  const AddTaskWidget({super.key});

  @override
  ConsumerState<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends ConsumerState<AddTaskWidget> {
  final titleController = TextEditingController();
  final tagController = TextEditingController();
  final dueDateController = TextEditingController();
  final noteController = TextEditingController();
  final focusTimeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    tagController.dispose();
    dueDateController.dispose();
    noteController.dispose();
    focusTimeController.dispose();
    super.dispose();
  }

  // Reset tag selection when dialog is closed
  void _resetTagSelection() {
    ref.read(selectedtagProvider.notifier).state = null;
  }

  Future<void> _addTask() async {
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a task title', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final task = Task(
        title: titleController.text.trim(),
        tags: tagController.text.trim(),
        dueDate: dueDateController.text.trim(),
        focusTime: focusTimeController.text.trim(),
        note: noteController.text.trim(),
      );

      await ref.read(taskListProvider.notifier).addTask(task);

      if (mounted) {
        _resetTagSelection();
        Navigator.of(context).pop();
        _showSnackBar('Task added successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error adding task: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // Format duration for display (e.g., "1h 30m")
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

  // Show duration picker dialog
  Future<void> _showDurationPicker() async {
    int selectedHours = 0;
    int selectedMinutes = 30; // Default to 30 minutes

    // Parse existing value if any
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
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
                    "Add New Task",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                _buildField("Title", titleController),
                const SizedBox(height: 12),

                TagSelector(controller: tagController, label: "Select Tag:"),

                const SizedBox(height: 12),

                // Date and Focus Time Row
                Row(
                  children: [
                    // Due Date Field
                    Expanded(
                      child: TextField(
                        controller: dueDateController,
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
                            dueDateController.text =
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
                _buildField("Add note", noteController, maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      _resetTagSelection();
                      Navigator.of(context).pop();
                    },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64D2FF),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
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
