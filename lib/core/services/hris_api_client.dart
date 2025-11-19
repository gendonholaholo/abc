import 'dart:math';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/attendance_log.dart';
import '../models/auth_session.dart';
import '../models/employee.dart';
import '../models/leave_request.dart';

class HrisApiClient {
  HrisApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConfig.baseUrl,
                connectTimeout: AppConfig.defaultTimeout,
                receiveTimeout: AppConfig.defaultTimeout,
              ),
            );

  final Dio _dio;
  final _rng = Random();
  final List<AttendanceLog> _fallbackLogs = [];
  final List<LeaveRequest> _fallbackRequests = [];

  void updateAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<AuthSession> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data ?? {};
      final token = data['token'] as String? ?? '';
      final profile =
          (data['employee'] ?? data['user']) as Map<String, dynamic>? ??
              {'id': 'unknown', 'name': email, 'email': email};
      final employee = Employee.fromJson(Map<String, dynamic>.from(profile));
      updateAuthToken(token);
      return AuthSession(token: token, employee: employee);
    } on DioException catch (err) {
      throw Exception(_prettyError(err, fallback: 'Gagal login, periksa kredensial.'));
    } catch (err) {
      throw Exception('Gagal login: $err');
    }
  }

  Future<AttendanceLog> clock({
    required AttendanceType type,
    String? location,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/attendance/${type == AttendanceType.clockIn ? 'clock-in' : 'clock-out'}',
        data: {
          if (location != null) 'location': location,
        },
      );
      final data = response.data ?? {};
      final log = AttendanceLog.fromJson(Map<String, dynamic>.from(data));
      return log;
    } on DioException catch (err) {
      final log = _createFallbackLog(type: type, location: location);
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return log;
      }
      throw Exception(_prettyError(err, fallback: 'Clock-in/out gagal'));
    }
  }

  Future<List<AttendanceLog>> fetchHistory() async {
    try {
      final response = await _dio.get<List<dynamic>>('/attendance/history');
      final data = response.data ?? [];
      return data
          .map((e) => AttendanceLog.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (err) {
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return List<AttendanceLog>.unmodifiable(_fallbackLogs.reversed.toList());
      }
      throw Exception(_prettyError(err, fallback: 'Gagal memuat riwayat'));
    }
  }

  Future<LeaveRequest> requestLeave({
    required LeaveType type,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/leave/request',
        data: {
          'type': type.name,
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
          'reason': reason,
        },
      );
      final data = response.data ?? {};
      return LeaveRequest.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (err) {
      final fallback = _createFallbackLeave(
        type: type,
        start: start,
        end: end,
        reason: reason,
      );
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return fallback;
      }
      throw Exception(_prettyError(err, fallback: 'Pengajuan cuti gagal'));
    }
  }

  Future<List<LeaveRequest>> fetchLeaveRequests() async {
    try {
      final response = await _dio.get<List<dynamic>>('/leave');
      final data = response.data ?? [];
      return data
          .map((e) => LeaveRequest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (err) {
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return List<LeaveRequest>.unmodifiable(_fallbackRequests.reversed.toList());
      }
      throw Exception(_prettyError(err, fallback: 'Gagal memuat data cuti'));
    }
  }

  AttendanceLog _createFallbackLog({
    required AttendanceType type,
    String? location,
  }) {
    final log = AttendanceLog(
      id: 'log-${_rng.nextInt(999999)}',
      employeeId: 'local',
      timestamp: DateTime.now(),
      type: type,
      location: location,
    );
    _fallbackLogs.add(log);
    return log;
  }

  LeaveRequest _createFallbackLeave({
    required LeaveType type,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) {
    final request = LeaveRequest(
      id: 'leave-${_rng.nextInt(99999)}',
      employeeId: 'local',
      reason: reason,
      startDate: start,
      endDate: end,
      type: type,
      status: 'pending (offline)',
    );
    _fallbackRequests.add(request);
    return request;
  }

  String _prettyError(DioException err, {required String fallback}) {
    final message = err.response?.data is Map<String, dynamic>
        ? (err.response?.data['message'] as String?)
        : null;
    return message ?? fallback;
  }
}
