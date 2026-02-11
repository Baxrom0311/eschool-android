import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';

/// User API — profil va farzandlar bilan bog'liq API so'rovlari
class UserApi {
  final DioClient _client;

  UserApi(this._client);

  /// Joriy foydalanuvchi profilini olish
  ///
  /// Tenant OAS bo'yicha `/api/me` da children bo'lmasligi mumkin, shu sabab
  /// children alohida endpointdan olinib birlashtiriladi.
  Future<UserModel> getProfile() async {
    try {
      final profileResponse = await _client.get(ApiConstants.profile);
      final profileJson = _normalizeUserJson(_asMap(profileResponse.data));

      List<ChildModel> children = const [];
      try {
        final childrenResponse = await _client.get(ApiConstants.children);
        children = _parseChildrenList(childrenResponse.data);
      } catch (_) {
        // Children endpoint xatoligi profil yuklanishini bloklamaydi.
      }

      final merged = <String, dynamic>{
        ...profileJson,
        'children': children.map((e) => e.toJson()).toList(),
      };
      return UserModel.fromJson(merged);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Profilni yangilash
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) async {
    final _ = (fullName, email, phone, notificationsEnabled);
    throw const ServerException(
      message:
          'Tenant Parent API bo\'yicha profilni yangilash endpointi mavjud emas.',
      statusCode: 405,
    );
  }

  /// Avatar yuklash
  Future<String> uploadAvatar(String filePath) async {
    final _ = filePath;
    throw const ServerException(
      message:
          'Tenant Parent API bo\'yicha avatar yuklash endpointi mavjud emas.',
      statusCode: 405,
    );
  }

  /// Farzandlar ro'yxatini olish
  Future<List<ChildModel>> getChildren() async {
    try {
      final response = await _client.get(ApiConstants.children);
      return _parseChildrenList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Bitta farzand tafsilotlari
  Future<ChildModel> getChildDetails(int childId) async {
    try {
      final response = await _client.get(ApiConstants.childDetails(childId));
      final root = _asMap(response.data);
      final student = root['student'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(root['student'] as Map<String, dynamic>)
          : root;

      return ChildModel.fromJson(_normalizeChildJson(student, root: root));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  List<ChildModel> _parseChildrenList(dynamic data) {
    final list = switch (data) {
      final Map<String, dynamic> map when map['children'] is List<dynamic> =>
        map['children'] as List<dynamic>,
      final List<dynamic> value => value,
      _ => const <dynamic>[],
    };

    return list
        .whereType<Map>()
        .map(
          (e) => ChildModel.fromJson(
            _normalizeChildJson(Map<String, dynamic>.from(e)),
          ),
        )
        .toList();
  }

  Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> raw) {
    final source = raw['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw['user'] as Map<String, dynamic>)
        : raw;

    final roles = source['roles'] is List
        ? (source['roles'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    return <String, dynamic>{
      'id': _toInt(source['id']),
      'full_name': (source['full_name'] ?? source['name'] ?? '').toString(),
      'phone': (source['phone'] ?? '').toString(),
      'email': source['email']?.toString(),
      'avatar_url': source['avatar_url'] ?? source['photo_url'],
      'role': (source['role'] ?? (roles.isNotEmpty ? roles.first : 'parent'))
          .toString(),
      'balance': _toInt(source['balance']),
      'contract_number': source['contract_number']?.toString(),
      'monthly_fee': _toInt(source['monthly_fee']),
      'children': source['children'] is List ? source['children'] : const [],
      'created_at': source['created_at']?.toString(),
      'notifications_enabled': source['notifications_enabled'] ?? true,
    };
  }

  Map<String, dynamic> _normalizeChildJson(
    Map<String, dynamic> source, {
    Map<String, dynamic>? root,
  }) {
    final group = source['group'] is Map<String, dynamic>
        ? source['group'] as Map<String, dynamic>
        : <String, dynamic>{};
    final klass = source['class'] is Map<String, dynamic>
        ? source['class'] as Map<String, dynamic>
        : <String, dynamic>{};
    final groupRow = root != null && root['groupRow'] is Map<String, dynamic>
        ? root['groupRow'] as Map<String, dynamic>
        : <String, dynamic>{};

    final classId = _toInt(
      source['class_id'] ??
          group['id'] ??
          klass['id'] ??
          groupRow['id'] ??
          groupRow['group_id'],
    );
    final className =
        (source['class_name'] ??
                source['class'] ??
                group['name'] ??
                klass['name'] ??
                groupRow['name'] ??
                groupRow['group_name'] ??
                'Sinf yo\'q')
            .toString();

    return <String, dynamic>{
      'id': _toInt(source['id']),
      'full_name': (source['full_name'] ?? source['name'] ?? '').toString(),
      'class_name': className,
      'class_id': classId,
      'avatar_url': source['avatar_url'],
      'average_grade': _toDouble(source['average_grade']),
      'attendance_percentage': _toInt(source['attendance_percentage']),
      'birth_date': source['birth_date']?.toString(),
    };
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  /// DioException → Custom Exception
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        String message = 'Server xatoligi';
        if (data is Map<String, dynamic>) {
          message =
              (data['message'] as String?) ??
              (data['error'] as String?) ??
              message;
        }

        if (statusCode == 401) {
          return AuthException(message: message);
        }
        if (statusCode == 422 && data is Map<String, dynamic>) {
          final errors = data['errors'];
          Map<String, List<String>>? validationErrors;
          if (errors is Map<String, dynamic>) {
            validationErrors = errors.map(
              (key, value) => MapEntry(
                key,
                (value is List) ? value.cast<String>() : [value.toString()],
              ),
            );
          }
          return ValidationException(
            message: message,
            errors: validationErrors,
          );
        }

        return ServerException(message: message, statusCode: statusCode);

      default:
        return const ServerException();
    }
  }
}
