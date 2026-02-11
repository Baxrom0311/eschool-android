import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_model.g.dart';

/// Vazifa holati
enum AssignmentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('submitted')
  submitted,
  @JsonValue('graded')
  graded,
  @JsonValue('overdue')
  overdue,
}

/// Topshiriq / uy vazifasi modeli
@JsonSerializable()
class AssignmentModel extends Equatable {
  final int id;

  /// Topshiriq sarlavhasi
  final String title;

  /// Tavsifi
  final String? description;

  /// Fan nomi
  @JsonKey(name: 'subject_name')
  final String subjectName;

  /// O'qituvchi
  @JsonKey(name: 'teacher_name')
  final String teacherName;

  /// Topshiriq holati
  final AssignmentStatus status;

  /// Topshirish muddati (ISO format)
  @JsonKey(name: 'due_date')
  final String dueDate;

  /// Berilgan sana
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// Baho (agar baholangan bo'lsa)
  final int? grade;

  /// O'qituvchi izohi
  @JsonKey(name: 'teacher_comment')
  final String? teacherComment;

  /// Biriktirilgan fayllar
  @JsonKey(defaultValue: [])
  final List<AttachmentModel> attachments;

  /// Topshirilgan javob fayllari
  @JsonKey(name: 'submitted_files', defaultValue: [])
  final List<AttachmentModel> submittedFiles;

  const AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.subjectName,
    required this.teacherName,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.grade,
    this.teacherComment,
    this.attachments = const [],
    this.submittedFiles = const [],
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentModelToJson(this);

  bool get isPending => status == AssignmentStatus.pending;
  bool get isSubmitted => status == AssignmentStatus.submitted;
  bool get isGraded => status == AssignmentStatus.graded;
  bool get isOverdue => status == AssignmentStatus.overdue;

  /// Holat matni
  String get statusText {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Kutilmoqda';
      case AssignmentStatus.submitted:
        return 'Topshirilgan';
      case AssignmentStatus.graded:
        return 'Baholangan';
      case AssignmentStatus.overdue:
        return 'Muddati o\'tgan';
    }
  }

  @override
  List<Object?> get props => [id, title, subjectName, status, dueDate];
}

/// Biriktirilgan fayl modeli
@JsonSerializable()
class AttachmentModel extends Equatable {
  final int? id;
  final String name;
  final String url;

  @JsonKey(name: 'file_size', defaultValue: 0)
  final int fileSize;

  @JsonKey(name: 'mime_type')
  final String? mimeType;

  const AttachmentModel({
    this.id,
    required this.name,
    required this.url,
    this.fileSize = 0,
    this.mimeType,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);

  /// Fayl hajmi formatlangan
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [id, name, url];
}
