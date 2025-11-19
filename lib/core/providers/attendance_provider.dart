import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_log.dart';
import '../services/hris_api_client.dart';
import '../storage/local_store.dart';
import 'session_provider.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceController, AsyncValue<List<AttendanceLog>>>(
  (ref) => AttendanceController(ref.read),
);

class AttendanceController extends StateNotifier<AsyncValue<List<AttendanceLog>>> {
  AttendanceController(this._read) : super(const AsyncValue.data([])) {
    loadHistory();
  }

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
      await _read(localStoreProvider).cacheLogs(logs);
      state = AsyncValue.data(logs);
    } catch (err, stack) {
      final cached = await _read(localStoreProvider).loadLogs();
      if (cached != null) {
        state = AsyncValue.data(cached);
        return;
      }
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
      await _read(localStoreProvider).cacheLogs(logs);
      state = AsyncValue.data(logs);
    } catch (err, stack) {
      final cached = await _read(localStoreProvider).loadLogs();
      if (cached != null) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }
}
