import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/assignment_model.dart';
import '../../models/attendance_model.dart';
import '../../models/grade_model.dart';
import '../../models/schedule_model.dart';
import 'api_helpers.dart';
import '../../../core/storage/local_cache_service.dart';

/// Academic API — baholar, jadval, topshiriqlar, davomat
///
/// Tenant parent OAS da ushbu ma'lumotlar turli wrapper formatlarda keladi.
/// Shu qatlamda ular UI ishlatayotgan modellarga transform qilinadi.
class AcademicApi with ApiHelpers {
  final DioClient _client;
  final LocalCacheService _cache;

  AcademicApi(this._client, this._cache);

  // ─── Baholar ───

  Future<List<GradeModel>> getGrades(int childId, {int? quarter}) async {
    try {
      final response = await _client.get(
        ApiConstants.grades(childId), 
        queryParameters: {
          'student_id': childId,
          if (quarter != null) 'quarter_id': quarter,
        },
      );
      final data = asMap(response.data);
      final bySubject = data['by_subject'] is List 
          ? (data['by_subject'] as List).whereType<Map>().toList() 
          : [];

      final results = <GradeModel>[];
      for (final subjectBlock in bySubject) {
        final subjectName = asMap(subjectBlock['subject'])['name']?.toString() ?? 'Fan';
        final grades = subjectBlock['grades'] is List 
            ? (subjectBlock['grades'] as List).whereType<Map>().toList() 
            : [];
            
        for (final g in grades) {
          final quarterNo = toInt(g['quarter']);
          if (quarter != null && quarterNo != quarter) continue;
          
          results.add(GradeModel.fromJson({
             'id': stableId(g), // Fake ID until backend yields real ID
             'subject_name': subjectName,
             'grade': toInt(g['grade_5']) > 0 ? toInt(g['grade_5']) : 0,
             'grade_type': 'quarter',
             'teacher_name': null,
             'comment': null,
             'created_at': (g['calculated_at'] ?? DateTime.now().toIso8601String()).toString(),
             'quarter': quarterNo == 0 ? 1 : quarterNo,
          }));
        }
      }
      return results;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<SubjectGradeSummary>> getGradeSummary(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.grades(childId), 
        queryParameters: {'student_id': childId},
      );
      final data = asMap(response.data);
      final bySubject = data['by_subject'] is List ? (data['by_subject'] as List).whereType<Map>().toList() : [];

      return bySubject.map((subjectBlock) {
          final subjectName = asMap(subjectBlock['subject'])['name']?.toString() ?? 'Fan';
          final grades = subjectBlock['grades'] is List ? (subjectBlock['grades'] as List).whereType<Map>().toList() : [];
          
          double sum = 0.0;
          for (var g in grades) { sum += toInt(g['grade_5']); }
          double average = grades.isNotEmpty ? (sum / grades.length) : 0.0;

          return SubjectGradeSummary.fromJson({
            'subject_name': subjectName,
            'average_grade': average,
            'total_grades': grades.length,
            'teacher_name': null,
          });
      }).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── Jadval ───

  Future<List<ScheduleModel>> getSchedule(int childId) async {
    final cacheKey = 'schedule_$childId';
    try {
      final response = await _client.get(
        ApiConstants.schedule(childId),
        queryParameters: {'student_id': childId, 'days': 7},
      );
      final root = asMap(response.data);
      
      // Save schedule to local cache
      await _cache.save(cacheKey, root);

      return _parseSchedule(root, childId);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
        final cachedData = await _cache.read(cacheKey);
        if (cachedData != null) {
          return _parseSchedule(asMap(cachedData), childId);
        }
      }
      throw handleDioError(e);
    }
  }

  List<ScheduleModel> _parseSchedule(Map<String, dynamic> root, int childId) {
    final entries = _extractScheduleEntries(root, childId);
    final gradingMode = _normalizeGradingMode(root['grading_mode']);

      return entries.map((entry) {
        final lessonTime = asMap(entry['lessonTime']);
        final subject = asMap(entry['subject']);
        final teacher = asMap(entry['teacher']);
        final room = asMap(entry['room']);
        final dateKey = entry['_date']?.toString();
        final mark = _resolveScheduleMark(
          root,
          childId: childId,
          entry: entry,
          dateKey: dateKey,
        );

        final fallbackDay = _weekdayFromDate(dateKey);
        final dayOfWeek = toInt(entry['day_of_week']) == 0
            ? fallbackDay
            : toInt(entry['day_of_week']);

        return ScheduleModel.fromJson({
          'id': toInt(entry['id']) == 0 ? stableId(entry) : toInt(entry['id']),
          'subject_name': (subject['name'] ?? 'Fan').toString(),
          'teacher_name': (teacher['name'] ?? 'O\'qituvchi').toString(),
          'start_time': (lessonTime['starts_at'] ?? '').toString(),
          'end_time': (lessonTime['ends_at'] ?? '').toString(),
          'day_of_week': dayOfWeek == 0 ? 1 : dayOfWeek,
          'lesson_number': toInt(
            lessonTime['lesson_no'] ??
                entry['lesson_number'] ??
                entry['lesson_no'] ??
                1,
          ),
          'room_number': room['name']?.toString(),
          'mark_value': _resolveTimetableMarkValue(mark, gradingMode),
          'mark_mode': gradingMode,
        });
      }).toList();
    }


  // ─── Topshiriqlar ───

  Future<List<AssignmentModel>> getAssignments(
    int childId, {
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.assignments(childId),
        queryParameters: {'student_id': childId},
      );
      final root = asMap(response.data);
      final gradingMode = _normalizeGradingMode(root['grading_mode']);
      var homeworks = _extractHomeworks(root, childId: childId);

      if (status != null && status.isNotEmpty) {
        homeworks = homeworks
            .where(
              (h) =>
                  _normalizeAssignmentStatus(h['status']) ==
                  status.toLowerCase(),
            )
            .toList();
      }

      return homeworks
          .map((homework) => _mapAssignment(homework, gradingMode: gradingMode))
          .toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AssignmentModel> getAssignmentDetails(int assignmentId, int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.parentHomeworkDetails(assignmentId),
        queryParameters: {'student_id': childId},
      );
      final root = asMap(response.data);
      final gradingMode = _normalizeGradingMode(root['grading_mode']);
      final homeworkData = asMap(root['homework']);

      if (homeworkData.isEmpty) {
        throw const ServerException(
          message: 'Topshiriq topilmadi',
          statusCode: 404,
        );
      }

      return _mapAssignment(homeworkData, gradingMode: gradingMode);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) async {
    if (filePath == null || filePath.isEmpty) {
      throw const ValidationException(
        message:
            'Tenant API bo\'yicha homework submit qilish uchun kamida bitta fayl yuborish majburiy.',
        errors: {
          'files': ['Kamida bitta fayl tanlang va yuboring.'],
        },
      );
    }

    await submitAssignmentWithFiles(
      assignmentId,
      filePaths: [filePath],
      text: text,
    );
  }

  Future<void> submitAssignmentWithFiles(
    int assignmentId, {
    required List<String> filePaths,
    String? text,
  }) async {
    try {
      if (filePaths.isEmpty) {
        throw const ValidationException(
          message:
              'Tenant API bo\'yicha homework submit qilish uchun kamida bitta fayl yuborish majburiy.',
          errors: {
            'files': ['Kamida bitta fayl tanlang va yuboring.'],
          },
        );
      }

      final childId = await _resolveHomeworkChildId(assignmentId);
      if (childId == null || childId <= 0) {
        throw const ServerException(
          message:
              'Homework uchun student_id aniqlanmadi. Qayta urinib ko\'ring.',
          statusCode: 422,
        );
      }

      final files = <MultipartFile>[];
      for (final path in filePaths) {
        final fileName = path.split('/').last;
        files.add(await MultipartFile.fromFile(path, filename: fileName));
      }

      final formData = FormData.fromMap({
        'student_id': childId,
        'files': files,
        if (text != null && text.isNotEmpty) 'note': text,
      });

      await _client.post(
        ApiConstants.submitAssignment(assignmentId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AttachmentModel> uploadAssignmentFile(
    int assignmentId,
    String filePath,
  ) async {
    try {
      final fileName = filePath.split('/').last;
      await submitAssignmentWithFiles(assignmentId, filePaths: [filePath]);

      return AttachmentModel.fromJson({
        'name': fileName,
        'url': filePath,
        'file_size': 0,
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── Davomat ───

  Future<List<AttendanceModel>> getAttendance(
    int childId, {
    String? month,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.attendance(childId),
        queryParameters: {'student_id': childId},
      );
      final data = asMap(response.data);
      final recordsRaw = data['records'] is List ? (data['records'] as List).whereType<Map>().toList() : [];

      final attendance = <AttendanceModel>[];
      for (final mark in recordsRaw) {
        final date = (mark['date'] ?? '').toString();
        if (date.isEmpty) continue;
        if (month != null && month.isNotEmpty && !date.startsWith(month)) continue;

        attendance.add(
          AttendanceModel.fromJson({
            'id': stableId(mark),
            'date': date,
            'status': (mark['status'] ?? '').toString().toLowerCase(),
            'subject_name': mark['subject']?.toString(),
            'reason': mark['note']?.toString(),
            'marked_by': mark['teacher']?.toString(),
          }),
        );
      }

      return attendance;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<AttendanceSummary> getAttendanceSummary(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.attendance(childId),
        queryParameters: {'student_id': childId},
      );
      final data = asMap(response.data);
      final summary = asMap(data['summary']);
      
      final total = toInt(summary['total']);
      final present = toInt(summary['present']);
      final percentage = total == 0 ? 0.0 : (present * 100.0) / total;

      return AttendanceSummary(
        totalDays: total,
        presentDays: present,
        absentDays: toInt(summary['absent']),
        lateDays: toInt(summary['late']),
        excusedDays: toInt(summary['excused']),
        attendancePercentage: percentage,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }


  List<Map<String, dynamic>> _extractScheduleEntries(
    Map<String, dynamic> root,
    int childId,
  ) {
    final result = <Map<String, dynamic>>[];

    if (root['schedule_by_child'] is Map) {
      final scheduleByChild = Map<String, dynamic>.from(
        root['schedule_by_child'] as Map,
      );
      final selected =
          scheduleByChild[childId.toString()] ??
          (scheduleByChild.isNotEmpty ? scheduleByChild.values.first : null);
      _appendScheduleContainer(result, selected);
      return result;
    }

    if (root['schedule_by_date'] is Map) {
      _appendScheduleContainer(result, root['schedule_by_date']);
      return result;
    }

    _appendScheduleContainer(result, root['entries']);
    return result;
  }

  Map<String, dynamic>? _resolveScheduleMark(
    Map<String, dynamic> root, {
    required int childId,
    required Map<String, dynamic> entry,
    String? dateKey,
  }) {
    final marksRaw = root['marks_by_child'];
    if (marksRaw is! Map) return null;

    final byChild = Map<String, dynamic>.from(marksRaw);
    final childMarks =
        byChild[childId.toString()] ??
        (byChild.isNotEmpty ? byChild.values.first : null);
    if (childMarks == null) return null;

    final entryId = toInt(entry['id']);
    if (entryId <= 0) return null;

    if (dateKey != null && dateKey.isNotEmpty) {
      final dateContainer = asMap(asMap(childMarks)[dateKey]);
      final markFromDate = _extractMarkForEntry(dateContainer, entryId);
      if (markFromDate != null) return markFromDate;
    }

    return _extractMarkForEntry(childMarks, entryId);
  }

  Map<String, dynamic>? _extractMarkForEntry(dynamic container, int entryId) {
    if (container is Map) {
      final map = Map<String, dynamic>.from(container);

      final direct = asMap(map[entryId.toString()]);
      if (_isTimetableMark(direct)) return direct;

      for (final value in map.values) {
        final mark = _extractMarkForEntry(value, entryId);
        if (mark != null) return mark;
      }
      return null;
    }

    if (container is List) {
      for (final item in container.whereType<Map>()) {
        final row = Map<String, dynamic>.from(item);
        final rowEntryId = toInt(
          row['timetable_entry_id'] ?? row['entry_id'] ?? row['id'],
        );
        if (rowEntryId == entryId && _isTimetableMark(row)) {
          return row;
        }

        final nested = _extractMarkForEntry(row, entryId);
        if (nested != null) return nested;
      }
    }

    return null;
  }

  bool _isTimetableMark(Map<String, dynamic> row) {
    return row.containsKey('grade_5') || row.containsKey('coin');
  }

  int? _resolveTimetableMarkValue(
    Map<String, dynamic>? row,
    String gradingMode,
  ) {
    if (row == null || row.isEmpty) return null;
    final grade5 = toNullableInt(row['grade_5']);
    final coin = toNullableInt(row['coin']);
    final value = gradingMode == 'coin' ? (coin ?? grade5) : (grade5 ?? coin);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _appendScheduleContainer(
    List<Map<String, dynamic>> out,
    dynamic container,
  ) {
    if (container is Map) {
      final map = Map<String, dynamic>.from(container);
      map.forEach((date, value) {
        if (value is List) {
          for (final item in value.whereType<Map>()) {
            out.add({
              ...Map<String, dynamic>.from(item),
              '_date': date.toString(),
            });
          }
        }
      });
      return;
    }

    if (container is List) {
      for (final item in container.whereType<Map>()) {
        out.add(Map<String, dynamic>.from(item));
      }
    }
  }

  List<Map<String, dynamic>> _extractHomeworks(
    Map<String, dynamic> root, {
    int? childId,
  }) {
    final result = <Map<String, dynamic>>[];
    final byChildRaw = root['homeworks_by_child'];

    if (byChildRaw is Map) {
      final byChild = Map<String, dynamic>.from(byChildRaw);
      if (childId != null) {
        final selected = byChild[childId.toString()];
        if (selected is List) {
          for (final item in selected.whereType<Map>()) {
            result.add(Map<String, dynamic>.from(item));
          }
        }
      } else {
        for (final value in byChild.values) {
          if (value is List) {
            for (final item in value.whereType<Map>()) {
              result.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
      return result;
    }

    if (root['homeworks'] is List) {
      for (final item in (root['homeworks'] as List).whereType<Map>()) {
        result.add(Map<String, dynamic>.from(item));
      }
      return result;
    }

    if (root['items'] is List) {
      for (final item in (root['items'] as List).whereType<Map>()) {
        result.add(Map<String, dynamic>.from(item));
      }
    }

    return result;
  }

  AssignmentModel _mapAssignment(
    Map<String, dynamic> homework, {
    required String gradingMode,
  }) {
    final subject = asMap(homework['subject']);
    final teacher = asMap(homework['teacher']);
    final submissions = homework['submissions'] is List
        ? (homework['submissions'] as List).whereType<Map>().toList()
        : const <Map>[];

    final firstSubmission = submissions.isNotEmpty
        ? Map<String, dynamic>.from(submissions.first)
        : <String, dynamic>{};
    final submittedFilesRaw = firstSubmission['files'] is List
        ? (firstSubmission['files'] as List).whereType<Map>().toList()
        : const <Map>[];
    final submittedFiles = submittedFilesRaw.map((file) {
      final item = Map<String, dynamic>.from(file);
      return {
        'id': toInt(item['id']),
        'name': (item['original_name'] ?? item['file_path'] ?? 'file')
            .toString(),
        'url': (item['url'] ?? item['file_path'] ?? '').toString(),
        'file_size': toInt(item['size']),
        'mime_type': item['mime']?.toString(),
      };
    }).toList();

    final normalizedStatus = _normalizeAssignmentStatus(homework['status']);
    final grade5 = toNullableInt(firstSubmission['grade_5']);
    final coin = toNullableInt(firstSubmission['coin']);
    final resolvedGrade = gradingMode == 'coin'
        ? (coin ?? grade5)
        : (grade5 ?? coin);
    return AssignmentModel.fromJson({
      'id': toInt(homework['id']),
      'title': (homework['title'] ?? '').toString(),
      'description': homework['description']?.toString(),
      'subject_name': (subject['name'] ?? 'Fan').toString(),
      'teacher_name': (teacher['name'] ?? 'O\'qituvchi').toString(),
      'status': normalizedStatus,
      'due_date': (homework['due_at'] ?? '').toString(),
      'created_at': (homework['assigned_at'] ?? '').toString(),
      'grade': resolvedGrade,
      'teacher_comment': firstSubmission['note']?.toString(),
      'attachments': const <Map<String, dynamic>>[],
      'submitted_files': submittedFiles,
    });
  }

  String _normalizeAssignmentStatus(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase();
    switch (raw) {
      case 'submitted':
      case 'done':
      case 'sent':
        return 'submitted';
      case 'graded':
      case 'checked':
        return 'graded';
      case 'overdue':
      case 'expired':
      case 'late':
        return 'overdue';
      default:
        return 'pending';
    }
  }

  String _normalizeGradingMode(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase();
    return raw == 'coin' ? 'coin' : 'grade';
  }

  int? _resolveHomeworkChildIdFromPayload(
    Map<String, dynamic> root,
    int assignmentId,
  ) {
    final byChildRaw = root['homeworks_by_child'];
    if (byChildRaw is! Map) return null;

    final byChild = Map<String, dynamic>.from(byChildRaw);
    for (final entry in byChild.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is! List) continue;
      final found = value.whereType<Map>().any(
        (item) => toInt(item['id']) == assignmentId,
      );
      if (found) {
        final parsed = int.tryParse(key);
        return parsed ?? toInt(key);
      }
    }
    return null;
  }

  Future<int?> _resolveHomeworkChildId(int assignmentId) async {
    final response = await _client.get(ApiConstants.parentHomeworks);
    final root = asMap(response.data);
    return _resolveHomeworkChildIdFromPayload(root, assignmentId);
  }


  int _weekdayFromDate(String? dateKey) {
    if (dateKey == null || dateKey.isEmpty) return 0;
    final parsed = DateTime.tryParse(dateKey);
    return parsed?.weekday ?? 0;
  }
}
