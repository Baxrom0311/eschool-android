class DynamicFormModel {
  final int id;
  final String title;
  final String? description;
  final DateTime? expiresAt;
  final bool isPublished;
  final int submissionsCount;
  final bool hasSubmitted;

  DynamicFormModel({
    required this.id,
    required this.title,
    this.description,
    this.expiresAt,
    this.isPublished = true,
    this.submissionsCount = 0,
    this.hasSubmitted = false,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      isPublished: json['is_published'] ?? false,
      submissionsCount: json['submissions_count'] ?? 0,
      hasSubmitted: json['has_submitted'] ?? false,
    );
  }
}

class FormDetailModel {
  final int id;
  final String title;
  final String? description;
  final List<FormFieldSchema> fieldsSchema;
  final DateTime? expiresAt;
  final bool hasSubmitted;
  final List<String>? myAnswers;

  FormDetailModel({
    required this.id,
    required this.title,
    this.description,
    required this.fieldsSchema,
    this.expiresAt,
    required this.hasSubmitted,
    this.myAnswers,
  });

  factory FormDetailModel.fromJson(Map<String, dynamic> json) {
    final formJson = json['form'] is Map ? json['form'] : json;

    final schema = formJson['fields_schema'];
    List<FormFieldSchema> fields = [];
    if (schema is List) {
      fields = schema
          .map((e) => FormFieldSchema.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final mySubmission = json['my_submission'];
    List<String>? answers;
    if (mySubmission is Map && mySubmission['answers'] is List) {
      answers = (mySubmission['answers'] as List).map((e) => e.toString()).toList();
    } else if (mySubmission is List) {
      answers = mySubmission.map((e) => e.toString()).toList();
    }

    return FormDetailModel(
      id: formJson['id'] ?? 0,
      title: formJson['title'] ?? '',
      description: formJson['description'],
      fieldsSchema: fields,
      expiresAt: formJson['expires_at'] != null
          ? DateTime.tryParse(formJson['expires_at'])
          : null,
      hasSubmitted: json['has_submitted'] ?? false,
      myAnswers: answers,
    );
  }
}

class FormFieldSchema {
  final String label;
  final String type; // text, textarea, select, radio, checkbox, number, date
  final bool required;
  final List<String> options;

  FormFieldSchema({
    required this.label,
    this.type = 'text',
    this.required = false,
    this.options = const [],
  });

  factory FormFieldSchema.fromJson(Map<String, dynamic> json) {
    return FormFieldSchema(
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
