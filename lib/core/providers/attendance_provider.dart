import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_log.dart';
import '../services/hris_api_client.dart';
import 'session_provider.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceController, AsyncValue<List<AttendanceLog>>>(
  (ref) => AttendanceController(ref.read),
);

class AttendanceController extends StateNotifier<AsyncValue<List<AttendanceLog>>> {
  AttendanceController(this._read) : super(const AsyncValue.data([]));

  final Reader _read;

  Future<void> clockIn({String? location}) async {
    await _clock(type: AttendanceType.clockIn, location: location);
  }

  Future<void> clockOut({String? location}) async {
    await _clock(type: AttendanceType.clockOut, location: location);
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final logs = await _read(hrisClientProvider).fetchHistory();
      state = AsyncValue.data(logs);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }

  Future<void> _clock({
    required AttendanceType type,
    String? location,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _read(hrisClientProvider).clock(type: type, location: location);
      final logs = await _read(hrisClientProvider).fetchHistory();
      state = AsyncValue.data(logs);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }
}
