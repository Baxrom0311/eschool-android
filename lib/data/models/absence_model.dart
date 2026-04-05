class AbsenceExcuseModel {
  final int id;
  final String dateFrom;
  final String dateTo;
  final String reason;
  final String status;
  final String? attachmentUrl;

  AbsenceExcuseModel({
    required this.id,
    required this.dateFrom,
    required this.dateTo,
    required this.reason,
    required this.status,
    this.attachmentUrl,
  });

  factory AbsenceExcuseModel.fromJson(Map<String, dynamic> json) {
    return AbsenceExcuseModel(
      id: json['id'] ?? 0,
      dateFrom: json['date_from']?.toString() ?? '',
      dateTo: json['date_to']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      attachmentUrl: json['attachment_url']?.toString(),
    );
  }
}
