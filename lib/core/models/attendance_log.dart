import 'dart:convert';

enum AttendanceType { clockIn, clockOut }

class AttendanceLog {
  const AttendanceLog({
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

  String get label => type == AttendanceType.clockIn ? 'Clock in' : 'Clock out';
  String get formattedDate => timestamp.toLocal().toIso8601String();

  factory AttendanceLog.fromJson(Map<String, dynamic> json) => AttendanceLog(
        id: json['id'] as String? ?? '',
        employeeId: json['employee_id'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(
                (json['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch)),
        type: _parseType(json['type'] as String? ?? ''),
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        if (location != null) 'location': location,
      };

  factory AttendanceLog.fromEncoded(String data) =>
      AttendanceLog.fromJson(jsonDecode(data) as Map<String, dynamic>);

  String encode() => jsonEncode(toJson());
}

AttendanceType _parseType(String raw) {
  switch (raw.toLowerCase()) {
    case 'clockout':
    case 'clock_out':
      return AttendanceType.clockOut;
    case 'clockin':
    case 'clock_in':
    default:
      return AttendanceType.clockIn;
  }
}
