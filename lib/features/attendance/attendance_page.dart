import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/attendance_provider.dart';
import '../../core/providers/session_provider.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Karyawan: ${session.employee?.name ?? '-'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => ref
                          .read(attendanceProvider.notifier)
                          .clockIn(location: 'Office'),
                  icon: const Icon(Icons.login),
                  label: const Text('Clock In'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => ref
                          .read(attendanceProvider.notifier)
                          .clockOut(location: 'Office'),
                  icon: const Icon(Icons.logout),
                  label: const Text('Clock Out'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Riwayat Terbaru',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  onPressed: () =>
                      ref.read(attendanceProvider.notifier).loadHistory(),
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.when(
                data: (logs) => logs.isEmpty
                    ? const Center(child: Text('Belum ada data absensi'))
                    : ListView.separated(
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: logs.length,
                      ),
                error: (err, _) => Text('Terjadi kesalahan: $err'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
