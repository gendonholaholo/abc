import 'dart:math';

import '../models/attendance_log.dart';
import '../models/employee.dart';
import '../models/leave_request.dart';

class HrisApiClient {
  HrisApiClient();

  final _rng = Random();
  final List<AttendanceLog> _logs = [];
  final List<LeaveRequest> _requests = [];
  Employee? _sessionEmployee;

  Future<Employee> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _sessionEmployee = Employee(
      id: 'emp-${_rng.nextInt(9999)}',
      name: 'Demo User',
      email: email,
    );
    return _sessionEmployee!;
  }

  Future<AttendanceLog> clock({
    required AttendanceType type,
    String? location,
  }) async {
    final employee = _sessionEmployee;
    if (employee == null) {
      throw StateError('No session active. Please login first.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final log = AttendanceLog(
      id: 'log-${_rng.nextInt(999999)}',
      employeeId: employee.id,
      timestamp: DateTime.now(),
      type: type,
      location: location,
    );
    _logs.add(log);
    return log;
  }

  Future<List<AttendanceLog>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<AttendanceLog>.unmodifiable(_logs.reversed.toList());
  }

  Future<LeaveRequest> requestLeave({
    required LeaveType type,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async {
    final employee = _sessionEmployee;
    if (employee == null) {
      throw StateError('No session active. Please login first.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final req = LeaveRequest(
      id: 'leave-${_rng.nextInt(99999)}',
      employeeId: employee.id,
      reason: reason,
      startDate: start,
      endDate: end,
      type: type,
    );
    _requests.add(req);
    return req;
  }

  Future<List<LeaveRequest>> fetchLeaveRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<LeaveRequest>.unmodifiable(_requests.reversed.toList());
  }
}
