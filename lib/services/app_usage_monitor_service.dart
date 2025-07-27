import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usage_stats/usage_stats.dart';

class AppUsageState {
  final Duration totalScreentime;
  final int unlocksCount;
  final List<Map<String, String>> mostUsedApps;
  final bool hasPermission;
  final bool isLoading;
  final String? errorMsg;

  AppUsageState({
    this.totalScreentime = Duration.zero,
    this.unlocksCount = 0,
    this.mostUsedApps = const [],
    this.hasPermission = false,
    this.isLoading = true,
    this.errorMsg,
  });

  AppUsageState copyWith({
    Duration? totalScreentime,
    int? unlocksCount,
    List<Map<String, String>>? mostUsedApps,
    bool? hasPermission,
    bool? isLoading,
    String? errorMsg,
  }) {
    return AppUsageState(
      totalScreentime: totalScreentime ?? this.totalScreentime,
      unlocksCount: unlocksCount ?? this.unlocksCount,
      mostUsedApps: mostUsedApps ?? this.mostUsedApps,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

class AppUsageMonitorNotifier extends StateNotifier<AppUsageState> {
  AppUsageMonitorNotifier() : super(AppUsageState());

  Future<void> fetchUsageData() async {
    state = state.copyWith(isLoading: true, errorMsg: null);

    try {
      bool permissionGranted = await UsageStats.checkUsagePermission() ?? false;
      if (!permissionGranted) {
        state = state.copyWith(hasPermission: false, isLoading: false);
        return;
      }

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      Duration timeSinceMidnight = now.difference(startOfDay);

      print('Querying usage from: $startOfDay to: $now');
      print('Time since midnight: ${timeSinceMidnight.inMinutes} minutes');

      // Try multiple approaches to get usage data
      Map<String, Duration> appTimes = {};
      int unlockCount = 0;

      // Approach 1: Try events-based calculation
      try {
        print('Trying events-based approach...');
        appTimes = await _calculateUsageFromEvents(startOfDay, now);
        unlockCount = await _countUnlocksFromEvents(startOfDay, now);
        print('Events approach result: ${appTimes.length} apps');
      } catch (e) {
        print('Events approach failed: $e');
      }

      // Approach 2: If events failed or returned no data, use usage stats with smart filtering
      if (appTimes.isEmpty) {
        print('Falling back to usage stats approach...');
        appTimes = await _calculateUsageFromStats(startOfDay, now, timeSinceMidnight);
        print('Usage stats approach result: ${appTimes.length} apps');
      }

      // Approach 3: If still no data, try a broader time range
      if (appTimes.isEmpty) {
        print('Trying broader time range...');
        DateTime broaderStart = startOfDay.subtract(Duration(hours: 1));
        final broaderStats = await UsageStats.queryUsageStats(broaderStart, now);
        print('Broader query returned ${broaderStats.length} apps');

        for (var appStats in broaderStats) {
          String packageName = appStats.packageName ?? 'unknown';
          int totalMs = int.tryParse(appStats.totalTimeInForeground ?? '0') ?? 0;

          if (totalMs < 60000) continue; // Skip apps with less than 1 minute

          Duration appDuration = Duration(milliseconds: totalMs);

          // For broader range, assume at most the time since midnight
          if (appDuration > timeSinceMidnight) {
            appDuration = timeSinceMidnight;
          }

          appTimes[packageName] = appDuration;
          print('Found app: $packageName with ${appDuration.inMinutes}m');
        }
      }

      // Calculate total screen time
      Duration totalScreentime = Duration.zero;
      for (var duration in appTimes.values) {
        totalScreentime += duration;
      }

      // Sanity check - cap total screen time
      if (totalScreentime > timeSinceMidnight) {
        print('Capping total screen time from ${totalScreentime.inMinutes}m to ${timeSinceMidnight.inMinutes}m');
        totalScreentime = timeSinceMidnight;
      }

      // Prepare most used apps list
      final mostUsedApps = appTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topApps = mostUsedApps.map((e) {
        return {
          'packageName': e.key,
          'name': _getAppName(e.key),
          'time': _formatDuration(e.value),
        };
      }).toList();

      print('Final results:');
      print('Total apps: ${topApps.length}');
      print('Total screen time: ${totalScreentime.inMinutes} minutes');
      print('Unlock count: $unlockCount');

      for (var app in topApps.take(5)) {
        print('  ${app['name']}: ${app['time']}');
      }

      state = state.copyWith(
        totalScreentime: totalScreentime,
        unlocksCount: unlockCount,
        mostUsedApps: topApps,
        hasPermission: true,
        isLoading: false,
      );
    } catch (e) {
      print('Error fetching usage data: $e');
      state = state.copyWith(isLoading: false, errorMsg: e.toString());
    }
  }

  Future<Map<String, Duration>> _calculateUsageFromEvents(DateTime startOfDay, DateTime now) async {
    DateTime queryStart = startOfDay.subtract(Duration(hours: 2));
    final events = await UsageStats.queryEvents(queryStart, now);

    print('Found ${events.length} events');

    if (events.isEmpty) {
      throw Exception('No events found');
    }

    Map<String, Duration> appTimes = {};
    Map<String, DateTime> appStartTimes = {};
    Map<String, bool> activeAtMidnight = {};

    // Sort events by timestamp
    events.sort((a, b) {
      int timeA = int.tryParse(a.timeStamp ?? '0') ?? 0;
      int timeB = int.tryParse(b.timeStamp ?? '0') ?? 0;
      return timeA.compareTo(timeB);
    });

    for (var event in events) {
      String packageName = event.packageName ?? 'unknown';
      int timestamp = int.tryParse(event.timeStamp ?? '0') ?? 0;
      DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      if (eventTime.isBefore(startOfDay)) {
        // Track what was active before midnight
        if (event.eventType == 1) { // ACTIVITY_RESUMED
          activeAtMidnight[packageName] = true;
        } else if (event.eventType == 2) { // ACTIVITY_PAUSED
          activeAtMidnight[packageName] = false;
        }
      } else {
        // Process events after midnight
        switch (event.eventType) {
          case 1: // ACTIVITY_RESUMED
            if (activeAtMidnight[packageName] == true && !appStartTimes.containsKey(packageName)) {
              appStartTimes[packageName] = startOfDay;
            } else {
              appStartTimes[packageName] = eventTime;
            }
            break;

          case 2: // ACTIVITY_PAUSED
            if (appStartTimes.containsKey(packageName)) {
              DateTime startTime = appStartTimes[packageName]!;
              Duration sessionDuration = eventTime.difference(startTime);
              appTimes[packageName] = (appTimes[packageName] ?? Duration.zero) + sessionDuration;
              appStartTimes.remove(packageName);
            }
            break;
        }
      }
    }

    // Handle apps still running
    for (var entry in appStartTimes.entries) {
      String packageName = entry.key;
      DateTime startTime = entry.value;
      Duration sessionDuration = now.difference(startTime);
      appTimes[packageName] = (appTimes[packageName] ?? Duration.zero) + sessionDuration;
    }

    // Filter out very short usage
    appTimes.removeWhere((key, value) => value.inMilliseconds < 60000);

    return appTimes;
  }

  Future<Map<String, Duration>> _calculateUsageFromStats(DateTime startOfDay, DateTime now, Duration maxTime) async {
    final usageStats = await UsageStats.queryUsageStats(startOfDay, now);
    print('Usage stats returned ${usageStats.length} apps');

    Map<String, Duration> appTimes = {};

    for (var appStats in usageStats) {
      String packageName = appStats.packageName ?? 'unknown';
      int totalMs = int.tryParse(appStats.totalTimeInForeground ?? '0') ?? 0;

      print('App: $packageName, Time: ${totalMs}ms (${Duration(milliseconds: totalMs).inMinutes}m)');

      if (totalMs < 60000) continue; // Skip apps with less than 1 minute

      Duration appDuration = Duration(milliseconds: totalMs);

      // Apply smart filtering for cross-midnight sessions
      if (appDuration > maxTime) {
        // If usage exceeds time since midnight, it likely includes previous day usage
        // Use a conservative estimate: cap at 80% of time since midnight
        Duration cappedDuration = Duration(milliseconds: (maxTime.inMilliseconds * 0.8).round());
        print('Capping $packageName from ${appDuration.inMinutes}m to ${cappedDuration.inMinutes}m');
        appDuration = cappedDuration;
      }

      appTimes[packageName] = appDuration;
    }

    return appTimes;
  }

  Future<int> _countUnlocksFromEvents(DateTime startOfDay, DateTime now) async {
    final events = await UsageStats.queryEvents(startOfDay, now) ;
    int unlockCount = 0;

    for (var event in events) {
      if (event.eventType == 5) {
        unlockCount++;
      }
    }

    return unlockCount;
  }

  String _getAppName(String packageName) {
    // Extract a readable name from package name
    List<String> parts = packageName.split('.');
    if (parts.isNotEmpty) {
      return parts.last.replaceAll('_', ' ').toLowerCase();
    }
    return packageName;
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> requestPermission() async {
    await UsageStats.grantUsagePermission();
  }
}

final appUsageMonitorProvider =
StateNotifierProvider<AppUsageMonitorNotifier, AppUsageState>((ref) {
  return AppUsageMonitorNotifier();
});