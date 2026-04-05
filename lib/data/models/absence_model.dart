class AbsenceExcuseModel {
  final int id;
  final String dateFrom;
  final String dateTo;
  final String reason;
  final String status;
  final String? attachmentUrl;

  const AbsenceExcuseModel({
    required this.id,
    required this.dateFrom,
    required this.dateTo,
    required this.reason,
    required this.status,
    this.attachmentUrl,
  });

  factory AbsenceExcuseModel.fromJson(Map<String, dynamic> json) {
    final from =
        json['excuse_date']?.toString() ?? json['date_from']?.toString() ?? '';
    final to =
        json['excuse_date_to']?.toString() ??
        json['date_to']?.toString() ??
        from;

    return AbsenceExcuseModel(
      id: json['id'] ?? 0,
      dateFrom: from,
      dateTo: to,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      attachmentUrl:
          json['attachment_url']?.toString() ?? json['attachment']?.toString(),
    );
  }
}
