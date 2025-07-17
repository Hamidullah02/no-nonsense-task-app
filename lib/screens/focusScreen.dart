import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noslack/riverpod/timeprovider.dart';
import '../models/taskmodel.dart';
import '../widgets/timerdisplay_widget.dart';

List<int> parseTimeString(String timeString) {
  int hours = 0, minutes = 0, seconds = 0;
  final parts = timeString.split(' ');
  for (var part in parts) {
    if (part.endsWith('h')) {
      hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
    } else if (part.endsWith('m')) {
      minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
    } else if (part.endsWith('s')) {
      seconds = int.tryParse(part.replaceAll('s', '')) ?? 0;
    }
  }
  return [hours, minutes, seconds];
}

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});

  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage> {
  bool isFullScreen = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    isFullScreen = false;
  }

  @override
  void dispose() {
    isFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(timeprovider);
    final currentTaskId = ref.watch(currentTimerProvider);
    final task =  ref.watch(taskListProvider)
        .firstWhere((task) => task.id == currentTaskId);

    if (currentTaskId == null) {
      return Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No task selected for focus',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: Text('Go Back to Tasks'),
              ),
            ],
          ),
        ),
      );
    }

    final timerState = ref.watch(timerStateProvider(currentTaskId));

    if (time != null &&
        time.isNotEmpty &&
        timerState.originalDuration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timerStateProvider(currentTaskId).notifier).setTime(time);
      });
    }

    if (time == null || time.isEmpty) {
      return Center(
        child: Text('No Focus time set', style: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => context.go('/home'),
              icon: Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: () => {toggleFullScreen(), print(isFullScreen)},
              icon: Icon(
                isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                child: Text(task.title,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            SizedBox(height: 16),
            TimerDisplay(
              duration: timerState.remaining,
              size: 48.0,
              horizontalsize: 95,
              timerdivpadding: 15,
            ),
            SizedBox(height: 25),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      () =>
                          ref
                              .read(timerStateProvider(currentTaskId).notifier)
                              .reset(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.refresh_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (timerState.isRunning) {
                      ref
                          .read(timerStateProvider(currentTaskId).notifier)
                          .pause();
                    } else if (timerState.isPaused) {
                      ref
                          .read(timerStateProvider(currentTaskId).notifier)
                          .resume();
                    } else {
                      ref
                          .read(timerStateProvider(currentTaskId).notifier)
                          .start();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        timerState.isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
