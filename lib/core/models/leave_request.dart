import 'dart:convert';

enum LeaveType { annual, sick, unpaid }

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.status,
  });

  final String id;
  final String employeeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType type;
  final String? status;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'] as String? ?? '',
        employeeId: json['employee_id'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        startDate:
            DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
        endDate:
            DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
        type: _parseType(json['type'] as String? ?? ''),
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'reason': reason,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'type': type.name,
        if (status != null) 'status': status,
      };

  factory LeaveRequest.fromEncoded(String data) =>
      LeaveRequest.fromJson(jsonDecode(data) as Map<String, dynamic>);

  String encode() => jsonEncode(toJson());
}

LeaveType _parseType(String raw) {
  switch (raw.toLowerCase()) {
    case 'sick':
      return LeaveType.sick;
    case 'unpaid':
      return LeaveType.unpaid;
    case 'annual':
    default:
      return LeaveType.annual;
  }
}
