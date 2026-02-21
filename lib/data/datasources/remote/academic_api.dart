import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/assignment_model.dart';
import '../../models/attendance_model.dart';
import '../../models/grade_model.dart';
import '../../models/schedule_model.dart';
import 'api_helpers.dart';

/// Academic API — baholar, jadval, topshiriqlar, davomat
///
/// Tenant parent OAS da ushbu ma'lumotlar turli wrapper formatlarda keladi.
/// Shu qatlamda ular UI ishlatayotgan modellarga transform qilinadi.
class AcademicApi with ApiHelpers {
  final DioClient _client;

  AcademicApi(this._client);

  // ─── Baholar ───

  Future<List<GradeModel>> getGrades(int childId, {int? quarter}) async {
    try {
      final root = await _getChildProfile(childId);
      final rows = _extractQuarterGradeRows(root);

      final normalizedRows = rows.where((row) {
        if (quarter == null) return true;
        final rowQuarter = toInt(
          asMap(row['quarter'])['number'] ?? row['quarter_id'],
        );
        return rowQuarter == quarter;
      }).toList();

      return normalizedRows.map((row) {
        final grade5 = _resolveGrade(row);
        final quarterNo = toInt(
          asMap(row['quarter'])['number'] ?? row['quarter_id'],
        );
        return GradeModel.fromJson({
          'id': toInt(row['id']) == 0 ? stableId(row) : toInt(row['id']),
          'subject_name': _subjectNameFromGradeRow(row),
          'grade': grade5,
          'grade_type': 'quarter',
          'teacher_name': _teacherNameFromGradeRow(row),
          'comment': row['comment']?.toString(),
          'created_at':
              (row['calculated_at'] ?? DateTime.now().toIso8601String())
                  .toString(),
          'quarter': quarterNo == 0 ? 1 : quarterNo,
        });
      }).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<List<SubjectGradeSummary>> getGradeSummary(int childId) async {
    try {
      final root = await _getChildProfile(childId);

      final yMapRaw = root['yMap'];
      final subjectsRaw = root['subjects'];
      final subjects = subjectsRaw is Map
          ? Map<String, dynamic>.from(subjectsRaw)
          : <String, dynamic>{};

      final yearRows = <Map<String, dynamic>>[];
      if (yMapRaw is Map) {
        for (final value in yMapRaw.values) {
          final row = asMap(value);
          if (row.isNotEmpty) yearRows.add(row);
        }
      }

      if (yearRows.isNotEmpty) {
        return yearRows.map((row) {
          final subjectId = toInt(row['subject_id']);
          final subject = asMap(row['subject']);
          final subjectFromMap = asMap(subjects[subjectId.toString()]);

          final subjectName =
              (subject['name'] ??
                      subjectFromMap['name'] ??
                      row['subject_name'] ??
                      'Fan')
                  .toString();
          final grade5 = _resolveGrade(row);

          return SubjectGradeSummary.fromJson({
            'subject_name': subjectName,
            'average_grade': grade5 > 0 ? grade5.toDouble() : 0.0,
            'total_grades': 1,
            'teacher_name': null,
          });
        }).toList();
      }

      // Fallback: yMap bo'lmasa qMap asosida summary quramiz.
      final quarterRows = _extractQuarterGradeRows(root);
      final bySubject = <String, List<int>>{};

      for (final row in quarterRows) {
        final subject = _subjectNameFromGradeRow(row);
        if (subject.isEmpty) continue;
        final grade = _resolveGrade(row);
        if (grade <= 0) continue;
        bySubject.putIfAbsent(subject, () => <int>[]).add(grade);
      }

      return bySubject.entries.map((entry) {
        final grades = entry.value;
        final average = grades.isEmpty
            ? 0.0
            : grades.reduce((a, b) => a + b) / grades.length;
        return SubjectGradeSummary.fromJson({
          'subject_name': entry.key,
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
    try {
      final response = await _client.get(
        ApiConstants.schedule(childId),
        queryParameters: {'student_id': childId, 'days': 7},
      );
      final root = asMap(response.data);
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
      }).toList()..sort((a, b) {
        final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCompare != 0) return dayCompare;
        return a.lessonNumber.compareTo(b.lessonNumber);
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
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

  Future<AssignmentModel> getAssignmentDetails(int assignmentId) async {
    try {
      final response = await _client.get(ApiConstants.parentHomeworks);
      final root = asMap(response.data);
      final gradingMode = _normalizeGradingMode(root['grading_mode']);
      final homeworks = _extractHomeworks(root);

      final match = homeworks.cast<Map<String, dynamic>?>().firstWhere(
        (item) => toInt(item?['id']) == assignmentId,
        orElse: () => null,
      );
      if (match == null) {
        throw const ServerException(
          message: 'Topshiriq topilmadi',
          statusCode: 404,
        );
      }

      return _mapAssignment(match, gradingMode: gradingMode);
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
      final root = await _getChildProfile(childId);
      final marks = root['lessonMarks'] is List
          ? (root['lessonMarks'] as List).whereType<Map>().toList()
          : const <Map>[];

      final attendance = <AttendanceModel>[];
      for (final rawMark in marks) {
        final mark = Map<String, dynamic>.from(rawMark);
        final session = asMap(mark['session']);
        final type = (mark['type'] ?? '').toString().toLowerCase();
        final date = (session['lesson_date'] ?? session['date'] ?? '')
            .toString();
        if (date.isEmpty) continue;
        if (month != null && month.isNotEmpty && !date.startsWith(month)) {
          continue;
        }

        final status = _statusFromLessonMark(type, mark['score']);
        attendance.add(
          AttendanceModel.fromJson({
            'id': toInt(mark['id']) == 0 ? stableId(mark) : toInt(mark['id']),
            'date': date,
            'status': status,
            'subject_name': asMap(session['subject'])['name']?.toString(),
            'reason': mark['note']?.toString(),
            'marked_by': asMap(session['teacher'])['name']?.toString(),
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
      final records = await getAttendance(childId);
      final total = records.length;
      final present = records
          .where((e) => e.status == AttendanceStatus.present)
          .length;
      final absent = records
          .where((e) => e.status == AttendanceStatus.absent)
          .length;
      final late = records
          .where((e) => e.status == AttendanceStatus.late_)
          .length;
      final excused = records
          .where((e) => e.status == AttendanceStatus.excused)
          .length;
      final percentage = total == 0 ? 0.0 : (present * 100.0) / total;

      return AttendanceSummary(
        totalDays: total,
        presentDays: present,
        absentDays: absent,
        lateDays: late,
        excusedDays: excused,
        attendancePercentage: percentage,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> _getChildProfile(int childId) async {
    final response = await _client.get(ApiConstants.childDetails(childId));
    return asMap(response.data);
  }

  List<Map<String, dynamic>> _extractQuarterGradeRows(
    Map<String, dynamic> root,
  ) {
    final qMap = root['qMap'];
    if (qMap is! Map) return const [];

    final rows = <Map<String, dynamic>>[];
    for (final subjectValue in qMap.values) {
      if (subjectValue is! Map) continue;
      for (final quarterValue in subjectValue.values) {
        final row = asMap(quarterValue);
        if (row.isNotEmpty) rows.add(row);
      }
    }
    return rows;
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

  String _subjectNameFromGradeRow(Map<String, dynamic> row) {
    final subject = asMap(row['subject']);
    return (subject['name'] ?? row['subject_name'] ?? 'Fan').toString();
  }

  String? _teacherNameFromGradeRow(Map<String, dynamic> row) {
    final teacher = asMap(row['teacher']);
    final value = teacher['name'] ?? row['teacher_name'];
    return value?.toString();
  }

  int _resolveGrade(Map<String, dynamic> row) {
    final explicit = toNullableInt(row['grade_5'] ?? row['grade']);
    if (explicit != null && explicit > 0) return explicit;

    final percent = toNullableDouble(row['percent']);
    if (percent == null) return 0;
    if (percent >= 86) return 5;
    if (percent >= 71) return 4;
    if (percent >= 56) return 3;
    return 2;
  }

  String _statusFromLessonMark(String type, dynamic score) {
    final normalized = type.toLowerCase();
    if (normalized == 'attendance_absent' ||
        normalized == 'absent' ||
        normalized == 'a') {
      return 'absent';
    }
    if (normalized == 'attendance_late' ||
        normalized == 'late' ||
        normalized == 'l') {
      return 'late';
    }
    if (normalized == 'attendance_excused' || normalized == 'excused') {
      return 'excused';
    }
    if (normalized == 'attendance_present' ||
        normalized == 'present' ||
        normalized == 'p') {
      return 'present';
    }

    final numeric = toNullableDouble(score);
    if (numeric != null && numeric <= 0) return 'absent';
    return 'present';
  }

  int _weekdayFromDate(String? dateKey) {
    if (dateKey == null || dateKey.isEmpty) return 0;
    final parsed = DateTime.tryParse(dateKey);
    return parsed?.weekday ?? 0;
  }
}
