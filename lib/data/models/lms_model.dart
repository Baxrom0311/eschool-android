class CourseModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final int teacherId;

  CourseModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.teacherId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'published',
      teacherId: json['teacher_id'] ?? 0,
    );
  }
}
