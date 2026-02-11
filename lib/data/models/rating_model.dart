import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rating_model.g.dart';

/// Reyting modeli — o'quvchi reytingi
@JsonSerializable()
class RatingModel extends Equatable {
  final int? id;

  /// O'quvchi ismi
  @JsonKey(name: 'student_name')
  final String studentName;

  /// O'rni (1, 2, 3, ...)
  final int rank;

  /// Umumiy ball
  @JsonKey(name: 'total_score', defaultValue: 0.0)
  final double totalScore;

  /// O'rtacha baho
  @JsonKey(name: 'average_grade', defaultValue: 0.0)
  final double averageGrade;

  /// O'quvchi rasmi
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Menmi (joriy foydalanuvchining bolasi)
  @JsonKey(name: 'is_current', defaultValue: false)
  final bool isCurrent;

  const RatingModel({
    this.id,
    required this.studentName,
    required this.rank,
    this.totalScore = 0.0,
    this.averageGrade = 0.0,
    this.avatarUrl,
    this.isCurrent = false,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);

  /// Top 3 da ekanligini tekshirish
  bool get isTopThree => rank <= 3;

  /// Medal rangi
  String? get medalColor {
    switch (rank) {
      case 1:
        return 'gold';
      case 2:
        return 'silver';
      case 3:
        return 'bronze';
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, studentName, rank, totalScore];
}
