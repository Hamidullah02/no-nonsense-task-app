import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatelessWidget {
  final BuildContext parentContext;

  const CustomBottomNav({super.key, required this.parentContext});

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/usage')) return 1;
    if (location.startsWith('/focus')) return 2;
    if (location.startsWith('/stats')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 41, 38, 44).withOpacity(.3),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF64D2FF),
        unselectedItemColor: Colors.grey,
        currentIndex: _getIndex(parentContext),
        onTap: (index) {
          switch (index) {
            case 0:
              parentContext.go('/home');
              break;
            case 1:
              parentContext.go('/usage');
              break;
            case 2:
              parentContext.go('/focus');
              break;
            case 3:
              parentContext.go('/stats');
              break;
            case 4:
              parentContext.go('/more');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.data_usage), label: "Usage"),
          BottomNavigationBarItem(icon: Icon(Icons.center_focus_strong_outlined), label: "Focus"),
          BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "More"),
        ],
      ),
    );
  }
}
