import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

/// Davomat holati
enum AttendanceStatus {
  @JsonValue('present')
  present,
  @JsonValue('absent')
  absent,
  @JsonValue('late')
  late_,
  @JsonValue('excused')
  excused,
}

/// Davomat modeli — kunlik davomat yozuvi
@JsonSerializable()
class AttendanceModel extends Equatable {
  final int id;

  /// Sana (yyyy-MM-dd format)
  final String date;

  /// Holat
  final AttendanceStatus status;

  /// Fan nomi (agar fan bo'yicha bo'lsa)
  @JsonKey(name: 'subject_name')
  final String? subjectName;

  /// Izoh (sababli/sababsiz)
  final String? reason;

  /// O'qituvchi tomonidan belgilangan
  @JsonKey(name: 'marked_by')
  final String? markedBy;

  const AttendanceModel({
    required this.id,
    required this.date,
    required this.status,
    this.subjectName,
    this.reason,
    this.markedBy,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLate => status == AttendanceStatus.late_;
  bool get isExcused => status == AttendanceStatus.excused;

  /// Holat matni
  String get statusText {
    switch (status) {
      case AttendanceStatus.present:
        return 'Keldi';
      case AttendanceStatus.absent:
        return 'Kelmadi';
      case AttendanceStatus.late_:
        return 'Kechikdi';
      case AttendanceStatus.excused:
        return 'Sababli';
    }
  }

  @override
  List<Object?> get props => [id, date, status, subjectName];
}

/// Davomat xulosasi — umumiy statistika
@JsonSerializable()
class AttendanceSummary extends Equatable {
  @JsonKey(name: 'total_days', defaultValue: 0)
  final int totalDays;

  @JsonKey(name: 'present_days', defaultValue: 0)
  final int presentDays;

  @JsonKey(name: 'absent_days', defaultValue: 0)
  final int absentDays;

  @JsonKey(name: 'late_days', defaultValue: 0)
  final int lateDays;

  @JsonKey(name: 'excused_days', defaultValue: 0)
  final int excusedDays;

  @JsonKey(name: 'attendance_percentage', defaultValue: 0.0)
  final double attendancePercentage;

  const AttendanceSummary({
    this.totalDays = 0,
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
    this.excusedDays = 0,
    this.attendancePercentage = 0.0,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);

  @override
  List<Object?> get props => [
        totalDays,
        presentDays,
        absentDays,
        lateDays,
        excusedDays,
        attendancePercentage,
      ];
}
