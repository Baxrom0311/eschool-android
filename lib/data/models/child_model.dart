import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'child_model.g.dart';

/// Farzand ma'lumotlari modeli
///
/// API dan keladigan farzand obyekti. Ota-ona bir nechta
/// farzandga ega bo'lishi mumkin, har biri o'z sinfi va
/// baholariga ega.
@JsonSerializable()
class ChildModel extends Equatable {
  final int id;

  @JsonKey(name: 'full_name', readValue: _fullNameReader)
  final String fullName;

  @JsonKey(name: 'class', readValue: _classNameReader)
  final String className;

  @JsonKey(name: 'class_id') // Might be wrapped in 'group' object?
  final int? classId;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Umumiy o'rtacha baho (GPA), 0.0 - 5.0
  @JsonKey(name: 'average_grade', defaultValue: 0.0)
  final double averageGrade;

  /// Davomat foizi, 0 - 100
  @JsonKey(name: 'attendance_percentage', defaultValue: 0)
  final int attendancePercentage;

  @JsonKey(name: 'birth_date')
  final String? birthDate;

  const ChildModel({
    required this.id,
    required this.fullName,
    required this.className,
    required this.classId,
    this.avatarUrl,
    this.averageGrade = 0.0,
    this.attendancePercentage = 0,
    this.birthDate,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);

  ChildModel copyWith({
    int? id,
    String? fullName,
    String? className,
    int? classId,
    String? avatarUrl,
    double? averageGrade,
    int? attendancePercentage,
    String? birthDate,
  }) {
    return ChildModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      className: className ?? this.className,
      classId: classId ?? this.classId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      averageGrade: averageGrade ?? this.averageGrade,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  /// UI uchun qisqa ism (faqat ism va familiya)
  String get shortName {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return fullName;
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        className,
        classId,
        avatarUrl,
        averageGrade,
        attendancePercentage,
        birthDate,
      ];

  @override
  String toString() => 'ChildModel(id: $id, fullName: $fullName, class: $className)';
}

// JSON Readers
Object? _fullNameReader(Map json, String key) {
  return json['full_name'] ?? json['name'];
}

Object? _classNameReader(Map json, String key) {
  if (json['class_name'] != null) return json['class_name'];
  if (json['group'] is Map) return json['group']['name'];
  if (json['class'] is Map) return json['class']['name'];
  if (json['group'] is String) return json['group'];
  return 'Sinf yo\'q';
}
