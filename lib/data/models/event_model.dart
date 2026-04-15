class SchoolEventModel {
  final int id;
  final String title;
  final String? description;
  final String type; // holiday, exam, meeting, sport, other
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? creatorName;

  SchoolEventModel({
    required this.id,
    required this.title,
    this.description,
    this.type = 'other',
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.location,
    this.creatorName,
  });

  factory SchoolEventModel.fromJson(Map<String, dynamic> json) {
    return SchoolEventModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'other',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      creatorName: (json['creator'] is Map)
          ? json['creator']['name'] as String?
          : json['creator_name'] as String?,
    );
  }
}
