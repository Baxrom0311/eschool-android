import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

/// Dars jadvali modeli — kunlik va haftalik jadval
@JsonSerializable()
class ScheduleModel extends Equatable {
  final int id;

  /// Fan nomi
  @JsonKey(name: 'subject_name')
  final String subjectName;

  /// O'qituvchi
  @JsonKey(name: 'teacher_name')
  final String teacherName;

  /// Boshlanish vaqti (HH:mm format)
  @JsonKey(name: 'start_time')
  final String startTime;

  /// Tugash vaqti (HH:mm format)
  @JsonKey(name: 'end_time')
  final String endTime;

  /// Hafta kuni (1=Dushanba ... 6=Shanba)
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;

  /// Dars raqami (1, 2, 3, ...)
  @JsonKey(name: 'lesson_number')
  final int lessonNumber;

  /// Xona raqami
  @JsonKey(name: 'room_number')
  final String? roomNumber;

  const ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.lessonNumber,
    this.roomNumber,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  /// Hafta kuni nomi
  String get dayName {
    const days = [
      '',
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];
    return (dayOfWeek >= 1 && dayOfWeek <= 7) ? days[dayOfWeek] : '';
  }

  /// Qisqa vaqt diapazoni: "08:00 - 08:45"
  String get timeRange => '$startTime - $endTime';

  @override
  List<Object?> get props => [
        id,
        subjectName,
        teacherName,
        dayOfWeek,
        lessonNumber,
      ];
}
