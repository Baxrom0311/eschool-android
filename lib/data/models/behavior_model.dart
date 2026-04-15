class BehaviorIncidentModel {
  final int id;
  final int studentId;
  final String type; // positive / negative
  final String category;
  final String? description;
  final int points;
  final String? incidentDate;
  final String? reporterName;
  final String? studentName;

  BehaviorIncidentModel({
    required this.id,
    required this.studentId,
    required this.type,
    required this.category,
    this.description,
    this.points = 0,
    this.incidentDate,
    this.reporterName,
    this.studentName,
  });

  factory BehaviorIncidentModel.fromJson(Map<String, dynamic> json) {
    return BehaviorIncidentModel(
      id: json['id'] as int,
      studentId: json['student_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'positive',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      points: json['points'] as int? ?? 0,
      incidentDate: json['incident_date'] as String?,
      reporterName: (json['reporter'] is Map)
          ? json['reporter']['name'] as String?
          : json['reporter_name'] as String?,
      studentName: (json['student'] is Map)
          ? json['student']['name'] as String?
          : json['student_name'] as String?,
    );
  }

  bool get isPositive => type == 'positive';
}

class BehaviorSummaryModel {
  final int totalPositive;
  final int totalNegative;
  final int netScore;
  final int incidentsCount;
  final List<BehaviorIncidentModel> incidents;

  BehaviorSummaryModel({
    this.totalPositive = 0,
    this.totalNegative = 0,
    this.netScore = 0,
    this.incidentsCount = 0,
    this.incidents = const [],
  });

  factory BehaviorSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map ? json['summary'] : json;
    final incidentList = json['incidents'] ?? json['data'] ?? [];

    return BehaviorSummaryModel(
      totalPositive: summary['total_positive'] as int? ?? 0,
      totalNegative: summary['total_negative'] as int? ?? 0,
      netScore: summary['net_score'] as int? ?? 0,
      incidentsCount: summary['incidents_count'] as int? ?? 0,
      incidents: (incidentList as List)
          .map((e) => BehaviorIncidentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
