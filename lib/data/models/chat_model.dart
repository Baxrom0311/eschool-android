import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

/// Suhbat modeli — chat ro'yxati uchun
@JsonSerializable()
class ConversationModel extends Equatable {
  final int id;

  /// Suhbatdosh nomi (o'qituvchi yoki admin)
  @JsonKey(name: 'participant_name')
  final String participantName;

  /// Suhbatdosh roli
  @JsonKey(name: 'participant_role')
  final String? participantRole;

  /// Suhbatdosh rasmi
  @JsonKey(name: 'participant_avatar')
  final String? participantAvatar;

  /// Oxirgi xabar matni
  @JsonKey(name: 'last_message')
  final String? lastMessage;

  /// Oxirgi xabar vaqti
  @JsonKey(name: 'last_message_at')
  final String? lastMessageAt;

  /// O'qilmagan xabarlar soni
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;

  /// Online status (backenddan kelsa)
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;

  const ConversationModel({
    required this.id,
    required this.participantName,
    this.participantRole,
    this.participantAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [id, participantName, unreadCount, isOnline];

  /// UI Helpers
  // bool get isOnline => false; // Removed hardcoded getter
  DateTime? get lastMessageTime => lastMessageAt != null ? DateTime.tryParse(lastMessageAt!) : null;
}

/// Xabar turi
enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
}

/// Xabar modeli
@JsonSerializable()
class MessageModel extends Equatable {
  final int id;

  /// Xabar matni
  final String? content;

  /// Xabar turi
  final MessageType type;

  /// Yuboruvchi ID
  @JsonKey(name: 'sender_id')
  final int senderId;

  /// Yuboruvchi nomi
  @JsonKey(name: 'sender_name')
  final String senderName;

  /// Menmi yuborganman
  @JsonKey(name: 'is_mine', defaultValue: false)
  final bool isMine;

  /// Yuborilgan vaqt
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// O'qilganmi
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;

  /// Fayl URL (image/file uchun)
  @JsonKey(name: 'file_url')
  final String? fileUrl;

  /// Fayl nomi
  @JsonKey(name: 'file_name')
  final String? fileName;

  const MessageModel({
    required this.id,
    this.content,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.isMine = false,
    required this.createdAt,
    this.isRead = false,
    this.fileUrl,
    this.fileName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
  
  // UI Helpers
  bool get isMe => isMine;
  DateTime get timestamp => DateTime.tryParse(createdAt) ?? DateTime.now();

  @override
  List<Object?> get props => [id, content, type, senderId, createdAt];
}
