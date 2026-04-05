class ConferenceModel {
  final int id;
  final String date;
  final String time;
  final String teacherName;
  final String status;
  final String? zoomLink;

  ConferenceModel({
    required this.id,
    required this.date,
    required this.time,
    required this.teacherName,
    required this.status,
    this.zoomLink,
  });

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    return ConferenceModel(
      id: json['id'] ?? 0,
      date: json['date']?.toString() ?? '',
      time: json['time_slot']?.toString() ?? json['time']?.toString() ?? '',
      teacherName: json['teacher']?['name']?.toString() ?? json['teacher_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      zoomLink: json['zoom_link']?.toString(),
    );
  }
}
