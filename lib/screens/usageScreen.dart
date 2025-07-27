import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_usage_monitor_service.dart';

class UsagePage extends ConsumerStatefulWidget {
   UsagePage({Key? key}) : super(key: key);


  @override
  ConsumerState<UsagePage> createState() => _usagepageState();

}
class _usagepageState extends ConsumerState<UsagePage>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appUsageMonitorProvider.notifier).fetchUsageData();
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUsageMonitorProvider);


    return Scaffold(
      appBar: AppBar(title: Text('Usage Monitor')),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : !state.hasPermission
          ? Center(
        child: ElevatedButton(
          child: Text('Grant Usage Permission'),
          onPressed: () =>
              ref.read(appUsageMonitorProvider.notifier).requestPermission(),
        ),
      )
          : state.errorMsg != null
          ? Center(child: Text('Error: ${state.errorMsg}'))
          : ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Total Screen Time: ${state.totalScreentime.inMinutes} minutes'),
          Text('Unlocks: ${state.unlocksCount}'),
          SizedBox(height: 20),
          Text('Top Apps:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...state.mostUsedApps.map(
                (app) => ListTile(
              title: Text(app['name']!),
              trailing: Text(app['time']!),
            ),
          ),
        ],
      ),
    );
  }
}
