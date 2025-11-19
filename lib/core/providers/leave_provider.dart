import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leave_request.dart';
import '../services/hris_api_client.dart';
import '../storage/local_store.dart';

final leaveProvider =
    StateNotifierProvider<LeaveController, AsyncValue<List<LeaveRequest>>>(
  (ref) => LeaveController(ref.read),
);

class LeaveController extends StateNotifier<AsyncValue<List<LeaveRequest>>> {
  LeaveController(this._read) : super(const AsyncValue.data([])) {
    load();
  }

  final Reader _read;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _read(hrisClientProvider).fetchLeaveRequests();
      await _read(localStoreProvider).cacheLeaveRequests(requests);
      state = AsyncValue.data(requests);
    } catch (err, stack) {
      final cached = await _read(localStoreProvider).loadLeaveRequests();
      if (cached != null) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }

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
      final requests = await _read(hrisClientProvider).fetchLeaveRequests();
      await _read(localStoreProvider).cacheLeaveRequests(requests);
      state = AsyncValue.data(requests);
    } catch (err, stack) {
      final cached = await _read(localStoreProvider).loadLeaveRequests();
      if (cached != null) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }
}
