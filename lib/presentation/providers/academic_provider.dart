import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../data/datasources/remote/academic_api.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/academic_repository.dart';
import 'auth_provider.dart';

bool _isBackendSchemaError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('sqlstate') ||
      message.contains('unknown column') ||
      message.contains('groups.academic_year');
}

// ═══════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS
// ═══════════════════════════════════════════════════════════════

final academicApiProvider = Provider<AcademicApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AcademicApi(dioClient);
});

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  final api = ref.watch(academicApiProvider);
  return AcademicRepository(academicApi: api);
});

// ═══════════════════════════════════════════════════════════════
// GRADES PROVIDER (AsyncNotifier)
// ═══════════════════════════════════════════════════════════════

class GradesData {
  final List<GradeModel> grades;
  final List<SubjectGradeSummary> summary;
  final int selectedQuarter;

  const GradesData({
    this.grades = const [],
    this.summary = const [],
    this.selectedQuarter = 1,
  });

  GradesData copyWith({
    List<GradeModel>? grades,
    List<SubjectGradeSummary>? summary,
    int? selectedQuarter,
  }) {
    return GradesData(
      grades: grades ?? this.grades,
      summary: summary ?? this.summary,
      selectedQuarter: selectedQuarter ?? this.selectedQuarter,
    );
  }
}

class GradesNotifier extends AutoDisposeAsyncNotifier<GradesData> {
  @override
  FutureOr<GradesData> build() {
    return const GradesData();
  }

  Future<void> loadGrades(int childId, {int? quarter}) async {
    final repository = ref.read(academicRepositoryProvider);
    final targetQuarter = quarter ?? state.value?.selectedQuarter ?? 1;
    final cached = _readGradesCache(childId, targetQuarter);
    if (cached != null) {
      state = AsyncValue.data(cached);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final gradesResult = await repository.getGrades(
        childId,
        quarter: targetQuarter,
      );
      final grades = gradesResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );
      final summary = _buildSummaryFromGrades(grades);

      final data = GradesData(
        grades: grades,
        summary: summary,
        selectedQuarter: targetQuarter,
      );
      state = AsyncValue.data(data);
      unawaited(_saveGradesCache(childId, data));
    } catch (e, st) {
      if (cached != null && !_isBackendSchemaError(e)) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  List<SubjectGradeSummary> _buildSummaryFromGrades(List<GradeModel> grades) {
    final bySubject = <String, List<int>>{};
    final teacherBySubject = <String, String?>{};

    for (final grade in grades) {
      final subject = grade.subjectName.trim();
      if (subject.isEmpty) continue;
      bySubject.putIfAbsent(subject, () => <int>[]).add(grade.grade);
      teacherBySubject.putIfAbsent(subject, () => grade.teacherName);
    }

    return bySubject.entries.map((entry) {
      final values = entry.value;
      final average = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;
      return SubjectGradeSummary(
        subjectName: entry.key,
        averageGrade: average,
        totalGrades: values.length,
        teacherName: teacherBySubject[entry.key],
      );
    }).toList();
  }

  void selectQuarter(int quarter) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(selectedQuarter: quarter));
      // Note: Typically you'd re-fetch here if the data depends on the quarter,
      // but the original code just updated the state.
      // If re-fetch is needed, call loadGrades(childId, quarter: quarter).
    }
  }

  GradesData? _readGradesCache(int childId, int quarter) {
    final raw = SharedPrefsService.getString(_gradesCacheKey(childId, quarter));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final gradesRaw = map['grades'];
      final summaryRaw = map['summary'];
      final grades = gradesRaw is List
          ? gradesRaw
                .whereType<Map>()
                .map((e) => GradeModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <GradeModel>[];
      final summary = summaryRaw is List
          ? summaryRaw
                .whereType<Map>()
                .map(
                  (e) => SubjectGradeSummary.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const <SubjectGradeSummary>[];
      return GradesData(
        grades: grades,
        summary: summary,
        selectedQuarter: quarter,
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(_gradesCacheKey(childId, quarter)));
      return null;
    }
  }

  Future<void> _saveGradesCache(int childId, GradesData data) async {
    await SharedPrefsService.setString(
      _gradesCacheKey(childId, data.selectedQuarter),
      jsonEncode({
        'grades': data.grades.map((e) => e.toJson()).toList(),
        'summary': data.summary.map((e) => e.toJson()).toList(),
      }),
    );
  }

  String _gradesCacheKey(int childId, int quarter) =>
      '${StorageKeys.gradesCachePrefix}${childId}_q$quarter';
}

final gradesProvider =
    AsyncNotifierProvider.autoDispose<GradesNotifier, GradesData>(
      GradesNotifier.new,
    );

// ═══════════════════════════════════════════════════════════════
// SCHEDULE PROVIDER (AsyncNotifier)
// ═══════════════════════════════════════════════════════════════

class ScheduleData {
  final List<ScheduleModel> fullSchedule;
  final int selectedDay;

  const ScheduleData({this.fullSchedule = const [], this.selectedDay = 1});

  List<ScheduleModel> get todaySchedule {
    return fullSchedule.where((s) => s.dayOfWeek == selectedDay).toList()
      ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
  }
}

class ScheduleNotifier extends AutoDisposeAsyncNotifier<ScheduleData> {
  @override
  FutureOr<ScheduleData> build() {
    return const ScheduleData();
  }

  Future<void> loadSchedule(int childId) async {
    final repository = ref.read(academicRepositoryProvider);
    final cached = _readScheduleCache(childId);
    if (cached != null) {
      state = AsyncValue.data(cached);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final result = await repository.getSchedule(childId);
      final data = result.fold(
        (l) => throw Exception(l.message),
        (r) =>
            ScheduleData(fullSchedule: r, selectedDay: DateTime.now().weekday),
      );
      state = AsyncValue.data(data);
      unawaited(_saveScheduleCache(childId, data));
    } catch (e, st) {
      if (cached != null && !_isBackendSchemaError(e)) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  void selectDay(int day) {
    if (state.value != null) {
      final currentData = state.value!;
      state = AsyncValue.data(
        ScheduleData(fullSchedule: currentData.fullSchedule, selectedDay: day),
      );
    }
  }

  ScheduleData? _readScheduleCache(int childId) {
    final raw = SharedPrefsService.getString(_scheduleCacheKey(childId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final list = map['full_schedule'];
      final selectedDay = map['selected_day'] is int
          ? map['selected_day'] as int
          : DateTime.now().weekday;
      final fullSchedule = list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => ScheduleModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <ScheduleModel>[];
      return ScheduleData(
        fullSchedule: fullSchedule,
        selectedDay: selectedDay.clamp(1, 7),
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(_scheduleCacheKey(childId)));
      return null;
    }
  }

  Future<void> _saveScheduleCache(int childId, ScheduleData data) async {
    await SharedPrefsService.setString(
      _scheduleCacheKey(childId),
      jsonEncode({
        'full_schedule': data.fullSchedule.map((e) => e.toJson()).toList(),
        'selected_day': data.selectedDay,
      }),
    );
  }

  String _scheduleCacheKey(int childId) =>
      '${StorageKeys.scheduleCachePrefix}$childId';
}

final scheduleProvider =
    AsyncNotifierProvider.autoDispose<ScheduleNotifier, ScheduleData>(
      ScheduleNotifier.new,
    );

// ═══════════════════════════════════════════════════════════════
// ASSIGNMENTS PROVIDER (AsyncNotifier)
// ═══════════════════════════════════════════════════════════════

class AssignmentsData {
  final List<AssignmentModel> assignments;
  final AssignmentModel? selectedAssignment;

  const AssignmentsData({this.assignments = const [], this.selectedAssignment});
}

class AssignmentsNotifier extends AutoDisposeAsyncNotifier<AssignmentsData> {
  int? _lastChildId;
  String? _lastStatus;

  @override
  FutureOr<AssignmentsData> build() {
    return const AssignmentsData();
  }

  Future<void> loadAssignments(int childId, {String? status}) async {
    _lastChildId = childId;
    _lastStatus = status;
    final cacheKey = _assignmentsCacheKey(childId, status);
    final cachedAssignments = _readAssignmentsCache(cacheKey);
    final currentSelected = state.valueOrNull?.selectedAssignment;
    if (cachedAssignments != null) {
      state = AsyncValue.data(
        AssignmentsData(
          assignments: cachedAssignments,
          selectedAssignment: currentSelected,
        ),
      );
    } else {
      state = const AsyncValue.loading();
    }

    final repository = ref.read(academicRepositoryProvider);

    try {
      final result = await repository.getAssignments(childId, status: status);
      final assignments = result.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      final selectedAssignment = _resolveSelectedAssignment(
        currentSelected,
        assignments,
      );
      final data = AssignmentsData(
        assignments: assignments,
        selectedAssignment: selectedAssignment,
      );
      state = AsyncValue.data(data);
      unawaited(_saveAssignmentsCache(cacheKey, assignments));
    } catch (e, st) {
      if (cachedAssignments != null) {
        state = AsyncValue.data(
          AssignmentsData(
            assignments: cachedAssignments,
            selectedAssignment: currentSelected,
          ),
        );
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadAssignmentDetails(int assignmentId) async {
    final previousState = state.valueOrNull ?? const AssignmentsData();
    final cachedDetails = _readAssignmentDetailsCache(assignmentId);
    if (cachedDetails != null) {
      final updatedAssignments = _replaceAssignment(
        previousState.assignments,
        cachedDetails,
      );
      state = AsyncValue.data(
        AssignmentsData(
          assignments: updatedAssignments,
          selectedAssignment: cachedDetails,
        ),
      );
    }

    final repository = ref.read(academicRepositoryProvider);
    final result = await repository.getAssignmentDetails(assignmentId);

    result.fold(
      (l) {
        if (cachedDetails != null) return;
        state = AsyncValue.error(Exception(l.message), StackTrace.current);
      },
      (details) {
        final baseAssignments =
            state.valueOrNull?.assignments.isNotEmpty == true
            ? state.valueOrNull!.assignments
            : previousState.assignments;
        final updatedAssignments = _replaceAssignment(baseAssignments, details);
        state = AsyncValue.data(
          AssignmentsData(
            assignments: updatedAssignments,
            selectedAssignment: details,
          ),
        );
        unawaited(_saveAssignmentDetailsCache(details));
        if (_lastChildId != null) {
          unawaited(
            _saveAssignmentsCache(
              _assignmentsCacheKey(_lastChildId!, _lastStatus),
              updatedAssignments,
            ),
          );
        }
      },
    );
  }

  Future<bool> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) async {
    final repository = ref.read(academicRepositoryProvider);
    final result = await repository.submitAssignment(
      assignmentId,
      text: text,
      filePath: filePath,
    );

    return result.fold((l) => false, (r) => true);
  }

  AssignmentModel? _resolveSelectedAssignment(
    AssignmentModel? selected,
    List<AssignmentModel> assignments,
  ) {
    if (selected == null) return null;
    for (final item in assignments) {
      if (item.id == selected.id) {
        return item;
      }
    }
    return selected;
  }

  List<AssignmentModel> _replaceAssignment(
    List<AssignmentModel> assignments,
    AssignmentModel assignment,
  ) {
    if (assignments.isEmpty) return assignments;
    return assignments
        .map((item) => item.id == assignment.id ? assignment : item)
        .toList();
  }

  List<AssignmentModel>? _readAssignmentsCache(String key) {
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => AssignmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveAssignmentsCache(
    String key,
    List<AssignmentModel> assignments,
  ) async {
    await SharedPrefsService.setString(
      key,
      jsonEncode(assignments.map((e) => e.toJson()).toList()),
    );
  }

  AssignmentModel? _readAssignmentDetailsCache(int assignmentId) {
    final key = _assignmentDetailsCacheKey(assignmentId);
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return AssignmentModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveAssignmentDetailsCache(AssignmentModel details) async {
    await SharedPrefsService.setString(
      _assignmentDetailsCacheKey(details.id),
      jsonEncode(details.toJson()),
    );
  }

  String _assignmentsCacheKey(int childId, String? status) =>
      '${StorageKeys.assignmentsCachePrefix}${childId}_${status ?? 'all'}';

  String _assignmentDetailsCacheKey(int assignmentId) =>
      '${StorageKeys.assignmentDetailCachePrefix}$assignmentId';
}

final assignmentsProvider =
    AsyncNotifierProvider.autoDispose<AssignmentsNotifier, AssignmentsData>(
      AssignmentsNotifier.new,
    );

// ═══════════════════════════════════════════════════════════════
// ATTENDANCE PROVIDER (AsyncNotifier)
// ═══════════════════════════════════════════════════════════════

class AttendanceData {
  final List<AttendanceModel> records;
  final AttendanceSummary? summary;

  const AttendanceData({this.records = const [], this.summary});
}

class AttendanceNotifier extends AutoDisposeAsyncNotifier<AttendanceData> {
  @override
  FutureOr<AttendanceData> build() {
    return const AttendanceData();
  }

  Future<void> loadAttendance(int childId, {String? month}) async {
    final repository = ref.read(academicRepositoryProvider);
    final cacheKey = _attendanceCacheKey(childId, month);
    final cached = _readAttendanceCache(cacheKey);
    if (cached != null) {
      state = AsyncValue.data(cached);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final recordsResult = await repository.getAttendance(
        childId,
        month: month,
      );
      final records = recordsResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );
      final summary = _buildSummaryFromRecords(records);

      final data = AttendanceData(records: records, summary: summary);
      state = AsyncValue.data(data);
      unawaited(_saveAttendanceCache(cacheKey, data));
    } catch (e, st) {
      if (cached != null && !_isBackendSchemaError(e)) {
        state = AsyncValue.data(cached);
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  AttendanceSummary _buildSummaryFromRecords(List<AttendanceModel> records) {
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
  }

  AttendanceData? _readAttendanceCache(String key) {
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final recordsRaw = map['records'];
      final summaryRaw = map['summary'];
      final records = recordsRaw is List
          ? recordsRaw
                .whereType<Map>()
                .map(
                  (e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <AttendanceModel>[];
      final summary = summaryRaw is Map
          ? AttendanceSummary.fromJson(Map<String, dynamic>.from(summaryRaw))
          : null;
      return AttendanceData(records: records, summary: summary);
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveAttendanceCache(String key, AttendanceData data) async {
    await SharedPrefsService.setString(
      key,
      jsonEncode({
        'records': data.records.map((e) => e.toJson()).toList(),
        'summary': data.summary?.toJson(),
      }),
    );
  }

  String _attendanceCacheKey(int childId, String? month) =>
      '${StorageKeys.attendanceCachePrefix}${childId}_${month ?? 'all'}';
}

final attendanceProvider =
    AsyncNotifierProvider.autoDispose<AttendanceNotifier, AttendanceData>(
      AttendanceNotifier.new,
    );
