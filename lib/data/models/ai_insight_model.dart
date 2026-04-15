class AiInsightModel {
  final AiRiskPrediction riskPrediction;
  final List<AiTopicSuggestion> weakAreasSuggestions;
  final DateTime generatedAt;

  AiInsightModel({
    required this.riskPrediction,
    required this.weakAreasSuggestions,
    required this.generatedAt,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      riskPrediction: AiRiskPrediction.fromJson(json['risk_prediction'] ?? {}),
      weakAreasSuggestions: (json['weak_areas_suggestions'] as List? ?? [])
          .map((e) => AiTopicSuggestion.fromJson(e))
          .toList(),
      generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class AiRiskPrediction {
  final String riskLevel;
  final int riskScore;
  final double? attendanceRate;
  final double? avgGrade;
  final String aiAnalysis;

  AiRiskPrediction({
    required this.riskLevel,
    required this.riskScore,
    this.attendanceRate,
    this.avgGrade,
    required this.aiAnalysis,
  });

  factory AiRiskPrediction.fromJson(Map<String, dynamic> json) {
    return AiRiskPrediction(
      riskLevel: json['risk_level'] ?? 'Low',
      riskScore: json['risk_score'] ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble(),
      avgGrade: (json['avg_grade'] as num?)?.toDouble(),
      aiAnalysis: json['ai_analysis'] ?? '',
    );
  }
}

class AiTopicSuggestion {
  final String subject;
  final double? currentScore;
  final String aiAdvice;

  AiTopicSuggestion({
    required this.subject,
    this.currentScore,
    required this.aiAdvice,
  });

  factory AiTopicSuggestion.fromJson(Map<String, dynamic> json) {
    return AiTopicSuggestion(
      subject: json['subject'] ?? '',
      currentScore: (json['current_score'] as num?)?.toDouble(),
      aiAdvice: json['ai_advice'] ?? '',
    );
  }
}
