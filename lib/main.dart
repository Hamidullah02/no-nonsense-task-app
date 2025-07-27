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
import 'package:noslack/widgets/bottomnav_widget.dart';
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
      body: widget.child,
      bottomNavigationBar: CustomBottomNav(parentContext: context),
    );
  }
}




