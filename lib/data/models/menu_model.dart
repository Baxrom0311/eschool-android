import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

/// Ovqatlanish turi
enum MealType {
  @JsonValue('breakfast')
  breakfast,
  @JsonValue('lunch')
  lunch,
  @JsonValue('afternoon_tea')
  afternoonTea,
  @JsonValue('dinner')
  dinner,
  // Legacy cache/support.
  @JsonValue('snack')
  snack,
}

/// Kunlik menyu modeli
@JsonSerializable()
class MenuModel extends Equatable {
  final int id;

  /// Sana (yyyy-MM-dd)
  final String date;

  /// Ovqatlanish turi
  @JsonKey(name: 'meal_type')
  final MealType mealType;

  /// Taomlar ro'yxati
  @JsonKey(defaultValue: [])
  final List<DishModel> dishes;

  /// Umumiy kaloriya
  @JsonKey(name: 'total_calories', defaultValue: 0)
  final int totalCalories;

  const MenuModel({
    required this.id,
    required this.date,
    required this.mealType,
    this.dishes = const [],
    this.totalCalories = 0,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) =>
      _$MenuModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuModelToJson(this);

  /// Ovqatlanish turi matni
  String get mealTypeText {
    switch (mealType) {
      case MealType.breakfast:
        return 'Nonushta';
      case MealType.lunch:
        return 'Tushlik';
      case MealType.afternoonTea:
        return 'Poldnik';
      case MealType.dinner:
        return 'Kechki ovqat';
      case MealType.snack:
        return 'Tamaddi';
    }
  }

  @override
  List<Object?> get props => [id, date, mealType, dishes];
}

/// Taom modeli
@JsonSerializable()
class DishModel extends Equatable {
  final int? id;
  final String name;

  /// Tavsif yoki tarkibi
  final String? description;

  /// Kaloriya
  @JsonKey(defaultValue: 0)
  final int calories;

  /// Rasm URL
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const DishModel({
    this.id,
    required this.name,
    this.description,
    this.calories = 0,
    this.imageUrl,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) =>
      _$DishModelFromJson(json);

  Map<String, dynamic> toJson() => _$DishModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}
