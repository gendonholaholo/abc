import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_log.dart';
import '../models/employee.dart';
import '../models/leave_request.dart';

class LocalStore {
  static const _tokenKey = 'session_token';
  static const _employeeKey = 'session_employee';
  static const _logsKey = 'attendance_logs';
  static const _leaveKey = 'leave_requests';

  Future<void> persistSession({required String token, required Employee employee}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_employeeKey, employee.encode());
  }

  Future<(String token, Employee employee)?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final employeeRaw = prefs.getString(_employeeKey);
    if (token == null || employeeRaw == null) return null;
    return (token, Employee.fromEncoded(employeeRaw));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_employeeKey);
  }

  Future<void> cacheLogs(List<AttendanceLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  Future<List<AttendanceLog>?> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_logsKey);
    if (raw == null) return null;
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => AttendanceLog.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> cacheLeaveRequests(List<LeaveRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _leaveKey,
      jsonEncode(requests.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<LeaveRequest>?> loadLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_leaveKey);
    if (raw == null) return null;
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => LeaveRequest.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
