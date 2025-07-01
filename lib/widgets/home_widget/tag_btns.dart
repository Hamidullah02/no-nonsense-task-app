import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/taskmodel.dart';

const Map<String, Color> tagColors = {
  "Focus": Colors.blue,
  "Quick": Colors.orange,
  "Chore": Colors.green,
  "Study": Colors.purple,
  "Urgent": Colors.red,
  "Creative": Colors.teal,
};

Widget buildTagButton(
    String tag,
    TextEditingController controller,
    WidgetRef ref,
    ) {
  final selectedTag = ref.watch(selectedtagProvider);
  final isSelected = selectedTag == tag;
  final Color color = tagColors[tag] ?? Colors.grey;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 4 : 1,
      ),
      onPressed: () {
        if (isSelected) {
          // Deselect if already selected
          controller.text = '';
          ref.read(selectedtagProvider.notifier).state = null;
        } else {
          // Select new tag
          controller.text = tag;
          ref.read(selectedtagProvider.notifier).state = tag;
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            tag,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

// Optional: Create a reusable TagSelector widget
class TagSelector extends ConsumerWidget {
  final TextEditingController controller;
  final String? label;

  const TagSelector({
    super.key,
    required this.controller,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tagColors.keys
              .map((tag) => buildTagButton(tag, controller, ref))
              .toList(),
        ),
      ],
    );
  }
}
