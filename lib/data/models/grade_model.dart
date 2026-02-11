import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade_model.g.dart';

/// Baho modeli — fan bo'yicha baholar
@JsonSerializable()
class GradeModel extends Equatable {
  final int id;

  /// Fan nomi
  @JsonKey(name: 'subject_name')
  final String subjectName;

  /// Baho qiymati (1-5)
  final int grade;

  /// Baho turi: 'daily', 'exam', 'homework', 'test'
  @JsonKey(name: 'grade_type', defaultValue: 'daily')
  final String gradeType;

  /// O'qituvchi ismi
  @JsonKey(name: 'teacher_name')
  final String? teacherName;

  /// Izoh
  final String? comment;

  /// Baho qo'yilgan sana
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// Chorak (1-4)
  @JsonKey(defaultValue: 1)
  final int quarter;

  const GradeModel({
    required this.id,
    required this.subjectName,
    required this.grade,
    this.gradeType = 'daily',
    this.teacherName,
    this.comment,
    required this.createdAt,
    this.quarter = 1,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) =>
      _$GradeModelFromJson(json);

  Map<String, dynamic> toJson() => _$GradeModelToJson(this);

  /// Baho rangi uchun helper
  bool get isExcellent => grade == 5;
  bool get isGood => grade == 4;
  bool get isSatisfactory => grade == 3;
  bool get isPoor => grade <= 2;

  /// Baho turi matni
  String get gradeTypeText {
    switch (gradeType) {
      case 'daily':
        return 'Kunlik';
      case 'exam':
        return 'Imtihon';
      case 'homework':
        return 'Uy vazifasi';
      case 'test':
        return 'Test';
      default:
        return gradeType;
    }
  }

  @override
  List<Object?> get props => [id, subjectName, grade, gradeType, createdAt, quarter];
}

/// Fan bo'yicha baholar xulosasi
@JsonSerializable()
class SubjectGradeSummary extends Equatable {
  @JsonKey(name: 'subject_name')
  final String subjectName;

  @JsonKey(name: 'average_grade', defaultValue: 0.0)
  final double averageGrade;

  @JsonKey(name: 'total_grades', defaultValue: 0)
  final int totalGrades;

  @JsonKey(name: 'teacher_name')
  final String? teacherName;

  const SubjectGradeSummary({
    required this.subjectName,
    this.averageGrade = 0.0,
    this.totalGrades = 0,
    this.teacherName,
  });

  factory SubjectGradeSummary.fromJson(Map<String, dynamic> json) =>
      _$SubjectGradeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectGradeSummaryToJson(this);

  @override
  List<Object?> get props => [subjectName, averageGrade, totalGrades];
}
