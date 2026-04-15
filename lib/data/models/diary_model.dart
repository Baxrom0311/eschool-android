import 'package:json_annotation/json_annotation.dart';

part 'diary_model.g.dart';

@JsonSerializable()
class DiaryLessonModel {
  final int id;
  final String subject;
  final String teacher;
  final String? topic;
  final double? grade;
  @JsonKey(name: 'att_status')
  final String? attStatus;
  @JsonKey(name: 'att_label')
  final String? attLabel;
  @JsonKey(name: 'homework_note')
  final String? homeworkNote;
  @JsonKey(name: 'teacher_comment')
  final String? teacherComment;

  DiaryLessonModel({
    required this.id,
    required this.subject,
    required this.teacher,
    this.topic,
    this.grade,
    this.attStatus,
    this.attLabel,
    this.homeworkNote,
    this.teacherComment,
  });

  factory DiaryLessonModel.fromJson(Map<String, dynamic> json) => _$DiaryLessonModelFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryLessonModelToJson(this);
}

@JsonSerializable()
class DiaryDayModel {
  final String date;
  @JsonKey(name: 'day_name')
  final String dayName;
  final List<DiaryLessonModel> lessons;
  @JsonKey(name: 'avg_grade')
  final double? avgGrade;
  @JsonKey(name: 'lesson_count')
  final int lessonCount;
  @JsonKey(name: 'present_count')
  final int presentCount;

  DiaryDayModel({
    required this.date,
    required this.dayName,
    required this.lessons,
    this.avgGrade,
    required this.lessonCount,
    required this.presentCount,
  });

  factory DiaryDayModel.fromJson(Map<String, dynamic> json) => _$DiaryDayModelFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryDayModelToJson(this);
}


@JsonSerializable()
class DiaryWeekResponseModel {
  @JsonKey(name: 'student_id')
  final int studentId;
  @JsonKey(name: 'week_start')
  final String weekStart;
  @JsonKey(name: 'week_end')
  final String weekEnd;
  final List<DiaryDayModel> days;

  DiaryWeekResponseModel({
    required this.studentId,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  factory DiaryWeekResponseModel.fromJson(Map<String, dynamic> json) => _$DiaryWeekResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryWeekResponseModelToJson(this);
}

@JsonSerializable()
class DiarySummaryModel {
  @JsonKey(name: 'period_start')
  final String periodStart;
  @JsonKey(name: 'period_end')
  final String periodEnd;
  @JsonKey(name: 'total_lessons')
  final int totalLessons;
  @JsonKey(name: 'attendance_percent')
  final double attendancePercent;
  @JsonKey(name: 'avg_grade')
  final double? avgGrade;
  @JsonKey(name: 'homework_percent')
  final double homeworkPercent;
  @JsonKey(name: 'subject_grades')
  final Map<String, dynamic>? subjectGrades;
  @JsonKey(name: 'absent_count')
  final int absentCount;
  @JsonKey(name: 'late_count')
  final int lateCount;

  DiarySummaryModel({
    required this.periodStart,
    required this.periodEnd,
    required this.totalLessons,
    required this.attendancePercent,
    this.avgGrade,
    required this.homeworkPercent,
    this.subjectGrades,
    required this.absentCount,
    required this.lateCount,
  });

  factory DiarySummaryModel.fromJson(Map<String, dynamic> json) => _$DiarySummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$DiarySummaryModelToJson(this);
}
