import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leave_request.dart';
import '../services/hris_api_client.dart';
import 'session_provider.dart';

final leaveProvider =
    StateNotifierProvider<LeaveController, AsyncValue<List<LeaveRequest>>>(
  (ref) => LeaveController(ref.read),
);

class LeaveController extends StateNotifier<AsyncValue<List<LeaveRequest>>> {
  LeaveController(this._read) : super(const AsyncValue.data([]));

  final Reader _read;

  Future<void> submit({
    required LeaveType type,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _read(hrisClientProvider).requestLeave(
        type: type,
        start: start,
        end: end,
        reason: reason,
      );
      final items = await _read(hrisClientProvider).fetchLeaveRequests();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _read(hrisClientProvider).fetchLeaveRequests();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }
}
