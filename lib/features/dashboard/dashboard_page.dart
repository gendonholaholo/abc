import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../widgets/nav_shell.dart';
import '../attendance/attendance_page.dart';
import '../history/history_page.dart';
import '../leave/leave_request_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return NavShell(
      items: [
        NavDestination(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          builder: (_) => _DashboardHome(
            session: session,
            onLogout: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ),
        NavDestination(
          label: 'Absensi',
          icon: Icons.access_time,
          builder: (_) => const AttendancePage(),
        ),
        NavDestination(
          label: 'Riwayat',
          icon: Icons.list_alt,
          builder: (_) => const HistoryPage(),
        ),
        NavDestination(
          label: 'Cuti',
          icon: Icons.beach_access_outlined,
          builder: (_) => const LeaveRequestPage(),
        ),
      ],
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({required this.session, required this.onLogout});

  final SessionState session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HRIS Dashboard'),
        actions: [
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang, ${session.employee?.name ?? '-'}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Pantau status absensi, lakukan clock-in/out, dan ajukan cuti melalui menu di bawah.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _InfoCard(
                  title: 'Clock-in/out',
                  subtitle: 'Catat kehadiran harian dengan lokasi opsional.',
                  icon: Icons.access_time,
                ),
                _InfoCard(
                  title: 'Riwayat',
                  subtitle: 'Lihat rekap kehadiran Anda.',
                  icon: Icons.list_alt,
                ),
                _InfoCard(
                  title: 'Cuti',
                  subtitle: 'Ajukan cuti tahunan, sakit, atau tanpa bayar.',
                  icon: Icons.beach_access_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
