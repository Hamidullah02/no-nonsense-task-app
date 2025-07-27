// import 'package:flutter/services.dart';
//
// class UsageStatsService {
//   static const MethodChannel _channel = MethodChannel('com.noslack.app/usage_stats');
//
//
//   Future<Map<String, dynamic>> getDailyUsageStats() async {
//     try {
//       final Map<String, dynamic>? result = await _channel.invokeMapMethod('getDailyUsageStats');
//       return result ?? {};
//     } on PlatformException catch (e) {
//       print("Failed to get usage stats: '${e.message}'.");
//       return {};
//     }
//   }
//
//   Future<bool> requestUsagePermission() async {
//     try {
//       final bool? result = await _channel.invokeMethod('requestUsagePermission');
//       return result ?? false;
//     } on PlatformException catch (e) {
//       print("Failed to request permission: '${e.message}'.");
//       return false;
//     }
//   }
//
//   Future<bool> hasUsagePermission() async {
//     try {
//       final bool? result = await _channel.invokeMethod('hasUsagePermission');
//       return result ?? false;
//     } on PlatformException catch (e) {
//       print("Failed to check permission: '${e.message}'.");
//       return false;
//     }
//   }
// }
