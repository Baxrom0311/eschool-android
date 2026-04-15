class QuizModel {
  final int id;
  final String title;
  final String? description;
  final String? subjectName;
  final int? timeLimitMinutes;
  final int maxScore;
  final String? availableFrom;
  final String? availableUntil;
  final bool isAttempted;
  final int? lastScore;
  final double? lastPercent;

  QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.subjectName,
    this.timeLimitMinutes,
    this.maxScore = 0,
    this.availableFrom,
    this.availableUntil,
    this.isAttempted = false,
    this.lastScore,
    this.lastPercent,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      subjectName: json['subject_name'] as String?,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      maxScore: json['max_score'] as int? ?? 0,
      availableFrom: json['available_from'] as String?,
      availableUntil: json['available_until'] as String?,
      isAttempted: json['is_attempted'] as bool? ?? false,
      lastScore: json['last_score'] as int?,
      lastPercent: (json['last_percent'] as num?)?.toDouble(),
    );
  }
}

class QuizQuestion {
  final int index;
  final String question;
  final List<String> options;

  QuizQuestion({
    required this.index,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      index: json['index'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class QuizAttemptStart {
  final int attemptId;
  final String quizTitle;
  final int? timeLimitMinutes;
  final List<QuizQuestion> questions;

  QuizAttemptStart({
    required this.attemptId,
    required this.quizTitle,
    this.timeLimitMinutes,
    required this.questions,
  });

  factory QuizAttemptStart.fromJson(Map<String, dynamic> json) {
    return QuizAttemptStart(
      attemptId: json['attempt_id'] as int,
      quizTitle: json['quiz_title'] as String? ?? '',
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      questions: (json['questions'] as List?)
              ?.map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class QuizSubmitResult {
  final int score;
  final int maxScore;
  final double percent;

  QuizSubmitResult({
    required this.score,
    required this.maxScore,
    required this.percent,
  });

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResult(
      score: json['score'] as int? ?? 0,
      maxScore: json['max_score'] as int? ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }
}
