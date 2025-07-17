import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noslack/screens/focusScreen.dart';

class TimerState {
  final Duration remaining;
  final bool isRunning;
  final bool isPaused;
  final Duration originalDuration;
  final String taskId;

  TimerState({
    required this.remaining,
    required this.isRunning,
    this.isPaused = false,
    required this.originalDuration,
    required this.taskId,
  });
}

final activeTimerProvider = StateProvider<String?>((ref) => null);
final currentTimerProvider = StateProvider<String?>((ref) => null);
final timerStateProvider =
    StateNotifierProvider.family<TimerStateNotifier, TimerState, String>((
      ref,
      taskId,
    ) {
      return TimerStateNotifier(taskId, ref);
    });

class TimerStateNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final String taskid;
  final Ref ref;

  TimerStateNotifier(this.taskid, this.ref)
    : super(
        TimerState(
          remaining: Duration.zero,
          isRunning: false,
          taskId: taskid,
          originalDuration: Duration.zero,
        ),
      );

  void setTime(String timeString) {
    List<int> parts = parseTimeString(timeString);
    Duration duration = Duration(
      hours: parts[0],
      minutes: parts[1],
      seconds: parts[2],
    );
    state = TimerState(
      remaining: duration,
      taskId: taskid,
      isRunning: false,
      originalDuration: duration,
    );
  }

  void start() {
    if (state.isRunning) return;
    ref.read(activeTimerProvider.notifier).state = taskid;


    state = TimerState(
      remaining: state.remaining,
      isRunning: true,
      isPaused: false,
      originalDuration: state.originalDuration,
      taskId: taskid,
    );

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (state.remaining.inSeconds <= 0) {
        timer.cancel();
        state = TimerState(
          remaining: Duration.zero,
          isRunning: false,
          originalDuration: state.originalDuration,
          taskId: taskid,
        );
      } else {
        state = TimerState(
          remaining: Duration(seconds: state.remaining.inSeconds - 1),
          isRunning: true,
          originalDuration: state.originalDuration,
          taskId: taskid,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    if(ref.read(activeTimerProvider)==taskid){
      ref.read(activeTimerProvider.notifier).state=null;
    }

    state = TimerState(
      remaining: state.remaining,
      isRunning: false,
      isPaused: true,
      originalDuration: state.originalDuration,
      taskId: taskid,
    );
  }

  void resume() {
    if (!state.isPaused) return;
    start();
  }

  void reset() {
    _timer?.cancel();

    if(ref.read(activeTimerProvider)==taskid){
      ref.read(activeTimerProvider.notifier).state=null;
    }
    state = TimerState(
      remaining: state.originalDuration,
      isRunning: false,
      isPaused: false,
      originalDuration: state.originalDuration,
      taskId: taskid,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
