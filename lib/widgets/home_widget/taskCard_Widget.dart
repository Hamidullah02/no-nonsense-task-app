import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/taskmodel.dart';
import '../../screens/focusScreen.dart';
import 'editTask_widget.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final index;

  const TaskCard({super.key, required this.task, this.index});

  Widget build(BuildContext context) {
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
                      '#${task.tags}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Due: ${task.dueDate}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(width: 30),
              SizedBox(
                height: 50,
                width: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/focus');
                  },
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
