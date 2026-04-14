import 'user_model.dart';

class ParentLoginResponse {
  final String centralToken;
  final UserModel user;
  final List<ChildMappingModel> children;
  final ParentTenantSession? autoTenant;

  ParentLoginResponse({
    required this.centralToken,
    required this.user,
    required this.children,
    this.autoTenant,
  });

  factory ParentLoginResponse.fromJson(Map<String, dynamic> json) {
    return ParentLoginResponse(
      centralToken: json['token']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      children: (json['children'] as List? ?? [])
          .map((c) => ChildMappingModel.fromJson(c))
          .toList(),
      autoTenant: json['tenant'] != null 
          ? ParentTenantSession.fromJson(json['tenant']) 
          : null,
    );
  }
}

class ChildMappingModel {
  final int studentId;
  final String studentName;
  final String? studentEmail;
  final String? studentPhone;
  final String tenantId;
  final String schoolName;
  final String host;

  ChildMappingModel({
    required this.studentId,
    required this.studentName,
    this.studentEmail,
    this.studentPhone,
    required this.tenantId,
    required this.schoolName,
    required this.host,
  });

  factory ChildMappingModel.fromJson(Map<String, dynamic> json) {
    return ChildMappingModel(
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      studentName: json['student_name']?.toString() ?? '',
      studentEmail: json['student_email']?.toString(),
      studentPhone: json['student_phone']?.toString(),
      tenantId: json['tenant_id']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
    );
  }
}

class ParentTenantSession {
  final String tenantId;
  final int studentId;
  final String host;
  final String token;

  ParentTenantSession({
    required this.tenantId,
    required this.studentId,
    required this.host,
    required this.token,
  });

  factory ParentTenantSession.fromJson(Map<String, dynamic> json) {
    return ParentTenantSession(
      tenantId: json['tenant_id']?.toString() ?? '',
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      host: json['host']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}
