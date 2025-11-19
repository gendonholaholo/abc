enum LeaveStatus { pending, approved, rejected }

enum LeaveType { annual, sick, unpaid }

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.status = LeaveStatus.pending,
  });

  final String id;
  final String employeeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType type;
  final LeaveStatus status;

  String get label => switch (type) {
        LeaveType.annual => 'Annual',
        LeaveType.sick => 'Sick',
        LeaveType.unpaid => 'Unpaid',
      };
}
