import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/leave_provider.dart';

class LeaveRequestPage extends ConsumerStatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  ConsumerState<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends ConsumerState<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  DateTimeRange? _range;
  LeaveType _type = LeaveType.annual;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);

    ref.listen(leaveProvider, (previous, next) {
      if (next is AsyncData && previous != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan cuti dikirim')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Cuti')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<LeaveType>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Jenis cuti'),
                    items: LeaveType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(switch (e) {
                              LeaveType.annual => 'Tahunan',
                              LeaveType.sick => 'Sakit',
                              LeaveType.unpaid => 'Tanpa Bayar',
                            }),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _type = value ?? LeaveType.annual),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Alasan'),
                    validator: (value) =>
                        value != null && value.length > 5 ? null : 'Tuliskan alasan lebih detail',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _range == null
                              ? 'Pilih rentang tanggal'
                              : '${_range!.start.toLocal().toString().split(' ')[0]} - ${_range!.end.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 1),
                            initialDateRange: _range,
                          );
                          if (picked != null) {
                            setState(() => _range = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text('Pilih'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate() || _range == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lengkapi data termasuk rentang tanggal.'),
                                  ),
                                );
                                return;
                              }
                              ref.read(leaveProvider.notifier).submit(
                                    type: _type,
                                    start: _range!.start,
                                    end: _range!.end,
                                    reason: _reasonCtrl.text,
                                  );
                            },
                      icon: state.isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Kirim'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: state.when(
                data: (items) => items.isEmpty
                    ? const Center(child: Text('Belum ada pengajuan'))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final req = items[index];
                          return ListTile(
                            title: Text(req.label),
                            subtitle: Text(req.reason),
                            trailing: Text(req.status.name),
                          );
                        },
                      ),
                error: (err, _) => Center(child: Text('Error: $err')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
