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

  /// Ushbu dars uchun qo'yilgan baho/coin (agar mavjud bo'lsa)
  @JsonKey(name: 'mark_value')
  final int? markValue;

  /// Baho rejimi: grade | coin
  @JsonKey(name: 'mark_mode')
  final String? markMode;

  const ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.lessonNumber,
    this.roomNumber,
    this.markValue,
    this.markMode,
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

  /// Hozir bu dars davom etyaptimi?
  bool get isActive {
    final now = DateTime.now();
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    if (startParts.length < 2 || endParts.length < 2) return false;

    final startH = int.tryParse(startParts[0]) ?? -1;
    final startM = int.tryParse(startParts[1]) ?? -1;
    final endH = int.tryParse(endParts[0]) ?? -1;
    final endM = int.tryParse(endParts[1]) ?? -1;
    if (startH < 0 || startM < 0 || endH < 0 || endM < 0) return false;

    final nowMin = now.hour * 60 + now.minute;
    return nowMin >= startH * 60 + startM && nowMin <= endH * 60 + endM;
  }

  /// UI uchun baho/coin matni
  String? get markText {
    final value = markValue;
    if (value == null || value <= 0) return null;
    if ((markMode ?? '').toLowerCase() == 'coin') {
      return '$value coin';
    }
    return value.toString();
  }

  @override
  List<Object?> get props => [
    id,
    subjectName,
    teacherName,
    dayOfWeek,
    lessonNumber,
    markValue,
    markMode,
  ];
}
