import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../local/local_cache.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final hasPendingSync = LocalCache.hasPendingSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).cardColor,
            leading: Icon(
              hasPendingSync ? Icons.sync_problem : Icons.cloud_done_outlined,
              color: hasPendingSync ? Colors.amber : Colors.green,
            ),
            title: const Text('Offline Sync Status'),
            subtitle: Text(
              hasPendingSync
                  ? 'Write requests queued locally. Will sync when server is reconnected.'
                  : 'All transactions synced with server.',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Backend API URL'),
            subtitle: Text(ApiClient.baseUrl),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('Personal Expense Tracker v1.0.0'),
          ),
        ],
      ),
    );
  }
}
