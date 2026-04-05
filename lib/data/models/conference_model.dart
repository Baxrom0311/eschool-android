class ConferenceModel {
  final int id;
  final int slotId;
  final String date;
  final String time;
  final String teacherName;
  final String status;
  final String? location;
  final String? zoomLink;

  const ConferenceModel({
    required this.id,
    required this.slotId,
    required this.date,
    required this.time,
    required this.teacherName,
    required this.status,
    this.location,
    this.zoomLink,
  });

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    final slotSource =
        json['slot'] ?? json['conference_slot'] ?? json['conferenceSlot'];
    final slot = slotSource is Map
        ? Map<String, dynamic>.from(slotSource)
        : <String, dynamic>{};
    final teacher = slot['teacher'] is Map
        ? Map<String, dynamic>.from(slot['teacher'] as Map)
        : (json['teacher'] is Map
              ? Map<String, dynamic>.from(json['teacher'] as Map)
              : <String, dynamic>{});

    final startTime =
        slot['start_time']?.toString() ?? json['start_time']?.toString() ?? '';
    final endTime =
        slot['end_time']?.toString() ?? json['end_time']?.toString() ?? '';
    final location =
        slot['location']?.toString() ?? json['location']?.toString();
    final explicitZoomLink = json['zoom_link']?.toString();

    String? zoomLink = explicitZoomLink;
    if ((zoomLink == null || zoomLink.isEmpty) &&
        location != null &&
        (location.startsWith('http://') || location.startsWith('https://'))) {
      zoomLink = location;
    }

    return ConferenceModel(
      id: json['id'] as int? ?? 0,
      slotId:
          slot['id'] as int? ??
          json['conference_slot_id'] as int? ??
          json['id'] as int? ??
          0,
      date:
          slot['slot_date']?.toString() ??
          json['slot_date']?.toString() ??
          json['date']?.toString() ??
          '',
      time: startTime.isNotEmpty && endTime.isNotEmpty
          ? '$startTime - $endTime'
          : (json['time_slot']?.toString() ?? json['time']?.toString() ?? ''),
      teacherName:
          teacher['name']?.toString() ?? json['teacher_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      location: location,
      zoomLink: zoomLink,
    );
  }
}
