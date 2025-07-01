import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/taskmodel.dart';
import '../widgets/home_widget/addTask_widget.dart';
import '../widgets/home_widget/taskCard_Widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Tasks",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * .04,
                      child: SearchBar(
                        controller: searchController,
                        hintText: 'Search tasks...',
                        backgroundColor: WidgetStateProperty.all(
                          Color(0xFF2A2A45),
                        ),
                        hintStyle: WidgetStateProperty.all(
                          TextStyle(color: Colors.grey[400]),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        leading: Icon(Icons.search, color: Colors.white),
                        // onChanged: search(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: taskList.length,
                  itemBuilder: (_, i) {
                    return Dismissible(
                      key: Key(taskList[i].title),
                      background: Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.symmetric(vertical: 48),
                            color: Colors.green,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      secondaryBackground: Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(vertical: 48),
                            color: Colors.red,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.red,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          ref.read(taskListProvider.notifier).toggleDone(i);
                          return false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          ref.read(taskListProvider.notifier).removeTask(i);
                          return true;
                        }
                        return false;
                      },
                      child: TaskCard(task: taskList[i], index: i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Color(0xFF2A2A45),
            foregroundColor: Colors.white,
            onPressed: () async {
              final newTask = await showDialog<Task>(
                context: context,
                builder: (context) => const searchBar(),
              );
            },
            child: Icon(Icons.search),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            hoverColor: Colors.greenAccent,
            foregroundColor: Colors.white,
            onPressed: () async {
              ref.read(selectedtagProvider.notifier).state = null;
              final newTask = await showDialog<Task>(
                context: context,
                builder: (context) => const AddTaskWidget(),
              );
              if (newTask != null) {
                ref.read(taskListProvider.notifier).addTask(newTask);
              }
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class searchBar extends StatefulWidget {
  const searchBar({super.key});

  @override
  State<searchBar> createState() => _searchBarState();
}

class _searchBarState extends State<searchBar> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.08,
      height: MediaQuery.of(context).size.height * .04,
      child: SearchBar(
        controller: searchController,
        hintText: 'Search tasks...',
        backgroundColor: WidgetStateProperty.all(Color(0xFF2A2A45)),
        hintStyle: WidgetStateProperty.all(TextStyle(color: Colors.grey[400])),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        leading: Icon(Icons.search, color: Colors.white),
        // onChanged: search(),
      ),
    );
  }
}
