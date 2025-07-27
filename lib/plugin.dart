// import 'package:anim_search_bar/anim_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:noslack/riverpod/timeprovider.dart';
// import '../models/taskmodel.dart';
// import '../widgets/animated_searchbar.dart';
// import '../widgets/home_widget/addTask_widget.dart';
// import '../widgets/home_widget/taskCard_Widget.dart';
// import '../widgets/timerdisplay_widget.dart';
//
// class plugin extends ConsumerStatefulWidget {
//   const plugin({super.key});
//
//   @override
//   ConsumerState<plugin> createState() => _HomePageState();
// }
//
// class _HomePageState extends ConsumerState<plugin> {
//   final TextEditingController searchController = TextEditingController();
//   late List<Task> filteredtasks;
//
//   @override
//   void initState() {
//     super.initState();
//     filteredtasks = [];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final taskList = ref.watch(taskListProvider);
//     final activeTaskId = ref.watch(activeTimerProvider);
//     final timerState =
//     activeTaskId != null
//         ? ref.watch(timerStateProvider(activeTaskId))
//         : null;
//     final focusedTasks = taskList.where((task) => task.id == activeTaskId);
//     filteredtasks = filteredtasks.isEmpty ? taskList : filteredtasks;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     // Container(
//                     //   width: double.infinity,
//                     //   child: Stack(
//                     //     children: [
//                     //       Center(
//                     //         child: const Text(
//                     //           "Tasks",
//                     //           style: TextStyle(
//                     //             fontSize: 30,
//                     //             color: Colors.white,
//                     //           ),
//                     //         ),
//                     //       ),
//                     //       Positioned(
//                     //         right: 10,
//                     //         top: 0,
//                     //         child: AnimatedSearch(
//                     //           width: 0.7,
//                     //           textEditingController: searchController,
//                     //           startIcon: Icons.search,
//                     //           closeIcon: Icons.close,
//                     //           iconColor: Colors.white,
//                     //           cursorColor: Colors.white,
//                     //           onChanged: (String value) {
//                     //             setState(() {
//                     //               if (value.trim().isEmpty) {
//                     //                 filteredtasks = taskList;
//                     //               } else {
//                     //                 filteredtasks =
//                     //                     taskList
//                     //                         .where(
//                     //                           (task) => task.title
//                     //                           .toLowerCase()
//                     //                           .contains(
//                     //                         value.toLowerCase(),
//                     //                       ),
//                     //                     )
//                     //                         .toList();
//                     //               }
//                     //             });
//                     //           },
//                     //           decoration: InputDecoration(
//                     //             hintText: 'Search',
//                     //             hintStyle: TextStyle(
//                     //               color: Color.fromARGB(179, 95, 238, 251),
//                     //             ),
//                     //             border: InputBorder.none,
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     // InkWell(
//                     //   onTap: () => context.go('/focus'),
//                     //   child: Container(
//                     //     decoration: BoxDecoration(
//                     //       color: Color.fromARGB(255, 9, 131, 147),
//                     //       borderRadius: BorderRadius.circular(15),
//                     //     ),
//                     //     child:
//                     //     focusedTasks.isEmpty
//                     //         ? SizedBox(height: 0)
//                     //         : Container(
//                     //       padding: EdgeInsets.all(5),
//                     //       child: Row(
//                     //         mainAxisAlignment:
//                     //         MainAxisAlignment.spaceBetween,
//                     //         children: [
//                     //           CircleAvatar(
//                     //
//                     //             backgroundColor: Colors.red,
//                     //             radius: 7,
//                     //           ),
//                     //           Padding(
//                     //             padding: const EdgeInsets.symmetric(
//                     //               horizontal: 20,
//                     //             ),
//                     //             child: Text(focusedTasks.first.title),
//                     //           ),
//                     //           TimerDisplay(
//                     //             duration: timerState!.remaining,
//                     //             size: 15.0,
//                     //             horizontalsize: 40,
//                     //             timerdivpadding: 1,
//                     //           ),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     // SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredtasks.length,
//                   itemBuilder: (_, i) {
//                     return Dismissible(
//                       key: Key(filteredtasks[i].id),
//                       background: Stack(
//                         children: [
//                           Container(
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.only(left: 20),
//                             margin: const EdgeInsets.symmetric(vertical: 48),
//                             color: Colors.green,
//                           ),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Container(
//                               margin: const EdgeInsets.only(left: 20),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(40),
//                                 color: Colors.green,
//                               ),
//                               child: const Icon(
//                                 Icons.check_circle_outline,
//                                 color: Colors.white,
//                                 size: 35,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       secondaryBackground: Stack(
//                         children: [
//                           Container(
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.only(right: 20),
//                             margin: const EdgeInsets.symmetric(vertical: 48),
//                             color: Colors.red,
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Container(
//                               margin: const EdgeInsets.only(right: 20),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(40),
//                                 color: Colors.red,
//                               ),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: Colors.white,
//                                 size: 35,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       onDismissed: (direction) {
//                         final task = filteredtasks[i];
//
//                         if (direction == DismissDirection.endToStart) {
//                           ref.read(taskListProvider.notifier).removeTask(task.id);
//                           setState(() {
//                             filteredtasks.removeWhere((t) => t.id == task.id);
//                           });
//                         } else if (direction == DismissDirection.startToEnd) {
//                           ref.read(taskListProvider.notifier).toggleDoneById(task.id);
//                         }
//                       },
//
//
//
//                       child: TaskCard(task: filteredtasks[i], index: i),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         hoverColor: Colors.greenAccent,
//         foregroundColor: Colors.white,
//         onPressed: () async {
//           ref.read(selectedtagProvider.notifier).state = null;
//           final newTask = await showDialog<Task>(
//             context: context,
//             builder: (context) => const AddTaskWidget(),
//           );
//           if (newTask != null) {
//             ref.read(taskListProvider.notifier).addTask(newTask);
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
//
//
//
