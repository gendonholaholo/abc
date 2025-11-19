import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/attendance_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.when(
          data: (logs) => logs.isEmpty
              ? const Center(child: Text('Belum ada riwayat'))
              : ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final log = logs[index];
                    return ListTile(
                      leading: Icon(log.type == AttendanceType.clockIn
                          ? Icons.login
                          : Icons.logout),
                      title: Text(log.label),
                      subtitle: Text(log.formattedDate),
                      trailing: Text(log.location ?? '-'),
                    );
                  },
                ),
          error: (err, _) => Center(child: Text('Error: $err')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(attendanceProvider.notifier).loadHistory(),
        icon: const Icon(Icons.refresh),
        label: const Text('Muat ulang'),
      ),
    );
  }
}
