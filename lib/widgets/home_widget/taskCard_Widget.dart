import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noslack/riverpod/timeprovider.dart';
import '../../models/taskmodel.dart';
import 'editTask_widget.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final int index;

  const TaskCard({super.key, required this.task, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => editTaskWidget(task, index),
        );
      },
      child: Card(
        color: const Color(0xFF1E1E2E),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          task.isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.isDone ? Colors.greenAccent : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration:
                                  task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.tags,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Due: ${task.dueDate ?? 'No date'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 30),
              SizedBox(
                height: 50,
                width: 60,
                child: ElevatedButton(
                  onPressed:
                      task.focusTime != 'set time' && task.focusTime.isNotEmpty
                          ? () {
                            final activeTimer = ref.read(activeTimerProvider);
                            if (activeTimer != null && activeTimer != task.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Another task timer is already running!',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            ref.read(currentTimerProvider.notifier).state =
                                task.id;
                            ref.read(timeprovider.notifier).state =
                                task.focusTime;
                            context.go('/focus');
                          }
                          : null,
                  child: Icon(Icons.center_focus_strong),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
