import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  String id;
  String title;
  bool isDone;
  String tags;
  String note;
  String? dueDate;
  String focusTime;

  Task({
    this.id = '',
    required this.title,
    this.isDone = false,
    this.tags = '',
    this.dueDate = "__-__-__",
    this.note = 'no description',
    this.focusTime = 'set time',
  });

  factory Task.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      tags: data['tags'] ?? '',
      note: data['note'] ?? '',
      dueDate: data['dueDate'] ?? '__-__-__',
      focusTime: data['focusTime'] ?? 'time',
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'title': title,
      'isDone': isDone,
      'tags': tags,
      'note': note,
      'dueDate': dueDate,
      'focusTime': focusTime,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? tags,
    String? note,
    String? dueDate,
    String? focustime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      focusTime: focustime ?? this.focusTime,
    );
  }
}

final CollectionReference _tasks = FirebaseFirestore.instance.collection(
  'tasks',
);

class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final snapshot = await _tasks.get();
      final tasks =
          snapshot.docs.map((doc) => Task.fromFireStore(doc)).toList();
      state = tasks;
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final docref = await _tasks.add(task.toFireStore());
      final newTask = task.copyWith(id: docref.id);
      state = [...state, newTask];
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeTask(String id) async {
    try {
      await _tasks.doc(id).delete();
      state = state.where((t) => t.id != id).toList();
    } catch (e) {
      print(e);
    }
  }


  Future<void> editTask(Task updatedTask, int index) async {
    try {
      final task = state[index];
      final taskwithID = updatedTask.copyWith(id: task.id);
      await _tasks.doc(task.id).update(taskwithID.toFireStore());
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) taskwithID else state[i],
      ];
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleDoneById(String id) async{
    final index =state.indexWhere((t)=> t.id==id);
    if(index == -1 )return;
    final task = state[index];
    final updatedTask =task.copyWith(isDone: !task.isDone);

    try{
      await _tasks.doc(task.id).update({'isDone' : updatedTask.isDone});
      state =[
        for (int i = 0; i < state.length; i++)
          if (i == index) updatedTask else state[i],
      ];
    }
    catch(e){
      print(e);
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((
  ref,
) {
  return TaskListNotifier();
});

final selectedtagProvider = StateProvider<String?>((ref) => null);
final selectedColorProvider = StateProvider<Color>((ref) => Colors.grey);
final timeprovider = StateProvider<String?>((ref) => null);






