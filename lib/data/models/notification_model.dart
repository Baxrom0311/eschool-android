import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Bildirishnoma turi
enum NotificationType {
  @JsonValue('payment')
  payment,
  @JsonValue('grade')
  grade,
  @JsonValue('attendance')
  attendance,
  @JsonValue('assignment')
  assignment,
  @JsonValue('announcement')
  announcement,
  @JsonValue('chat')
  chat,
  @JsonValue('general')
  general,
}

/// Bildirishnoma modeli
@JsonSerializable()
class NotificationModel extends Equatable {
  final int id;

  /// Sarlavha
  final String title;

  /// Matn
  final String body;

  /// Turi
  final NotificationType type;

  /// O'qilganmi
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;

  /// Qo'shimcha ma'lumotlar (deeplink uchun)
  final Map<String, dynamic>? data;

  /// Yaratilgan vaqt
  @JsonKey(name: 'created_at')
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Turi bo'yicha ikon nomini qaytaradi (UI uchun)
  String get typeIcon {
    switch (type) {
      case NotificationType.payment:
        return 'payment';
      case NotificationType.grade:
        return 'grade';
      case NotificationType.attendance:
        return 'event_available';
      case NotificationType.assignment:
        return 'assignment';
      case NotificationType.announcement:
        return 'campaign';
      case NotificationType.chat:
        return 'chat';
      case NotificationType.general:
        return 'notifications';
    }
  }

  @override
  List<Object?> get props => [id, title, type, isRead, createdAt];
}
