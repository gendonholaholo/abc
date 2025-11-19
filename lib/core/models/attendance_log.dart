import 'package:intl/intl.dart';

enum AttendanceType { clockIn, clockOut }

class AttendanceLog {
  AttendanceLog({
    required this.id,
    required this.employeeId,
    required this.timestamp,
    required this.type,
    this.location,
  });

  final String id;
  final String employeeId;
  final DateTime timestamp;
  final AttendanceType type;
  final String? location;

  String get label =>
      type == AttendanceType.clockIn ? 'Clock In' : 'Clock Out';

  String get formattedDate =>
      DateFormat('EEE, dd MMM yyyy – HH:mm').format(timestamp);
}
