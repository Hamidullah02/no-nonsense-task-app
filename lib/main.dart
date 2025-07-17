import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noslack/screens/StatsScreen.dart';
import 'package:noslack/screens/focusScreen.dart';
import 'package:noslack/screens/homeScreen.dart';
import 'package:noslack/screens/moreScreen.dart';
import 'package:noslack/screens/usageScreen.dart';
import 'package:noslack/themedata.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized");
  } catch (e) {
    print("❌ Firebase init error: $e");
  }

  print("🔥 App started");
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => HomePage()),
        GoRoute(path: '/usage', builder: (context, state) => UsagePage()),
        GoRoute(path: '/focus', builder: (context, state) => FocusPage()),
        GoRoute(path: '/stats', builder: (context, state) => StatsPage()),
        GoRoute(path: '/more', builder: (context, state) => MorePage()),
      ],
    ),
    GoRoute(path: '/more', builder: (context, state) => MorePage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: darktheme,
      routerConfig: _router,
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("No Nonsense")),
      body: widget.child,
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 41, 38, 44).withOpacity(.3),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF64D2FF),
          unselectedItemColor: Colors.grey,
          currentIndex: _getIndex(context),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/usage');
                break;
              case 2:
                context.go('/focus');
                break;
              case 3:
                context.go('/stats');
                break;
              case 4:
                context.go('/more');
                break;
            }
          },

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
            BottomNavigationBarItem(
              icon: Icon(Icons.data_usage),
              label: "Usage",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.center_focus_strong_outlined),
              label: "Focus",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.query_stats),
              label: "Stats",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "More"),
          ],
        ),
      ),
    );
  }

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    print('Current path: ${GoRouterState.of(context).uri.path}');

    if (location == '/home') return 0;
    if (location == '/usage') return 1;
    if (location == '/focus') return 2;
    if (location == '/stats') return 3;
    if (location == '/more') return 4;
    return 0;
  }
}
