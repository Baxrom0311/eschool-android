import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/academic_api.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/academic_repository.dart';
import 'auth_provider.dart';

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
// GRADES STATE + PROVIDER
// ═══════════════════════════════════════════════════════════════

class GradesState {
  final List<GradeModel> grades;
  final List<SubjectGradeSummary> summary;
  final bool isLoading;
  final String? error;
  final int selectedQuarter;

  const GradesState({
    this.grades = const [],
    this.summary = const [],
    this.isLoading = false,
    this.error,
    this.selectedQuarter = 1,
  });

  const GradesState.initial()
    : grades = const [],
      summary = const [],
      isLoading = false,
      error = null,
      selectedQuarter = 1;

  GradesState copyWith({
    List<GradeModel>? grades,
    List<SubjectGradeSummary>? summary,
    bool? isLoading,
    String? error,
    int? selectedQuarter,
  }) {
    return GradesState(
      grades: grades ?? this.grades,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedQuarter: selectedQuarter ?? this.selectedQuarter,
    );
  }
}

class GradesNotifier extends StateNotifier<GradesState> {
  final AcademicRepository _repository;

  GradesNotifier({required AcademicRepository repository})
    : _repository = repository,
      super(const GradesState.initial());

  /// Baholar va xulosani parallel yuklash
  Future<void> loadGrades(int childId, {int? quarter}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedQuarter: quarter,
    );

    final results = await Future.wait([
      _repository.getGrades(childId, quarter: quarter),
      _repository.getGradeSummary(childId),
    ]);

    final gradesResult = results[0];
    final summaryResult = results[1];

    List<GradeModel> grades = [];
    List<SubjectGradeSummary> summary = [];
    String? error;

    gradesResult.fold(
      (f) => error = f.message,
      (g) => grades = g as List<GradeModel>,
    );

    summaryResult.fold(
      (f) => error ??= f.message,
      (s) => summary = s as List<SubjectGradeSummary>,
    );

    state = state.copyWith(
      grades: grades,
      summary: summary,
      isLoading: false,
      error: error,
    );
  }

  void selectQuarter(int quarter) {
    state = state.copyWith(selectedQuarter: quarter);
  }
}

final gradesProvider = StateNotifierProvider<GradesNotifier, GradesState>((
  ref,
) {
  final repository = ref.watch(academicRepositoryProvider);
  return GradesNotifier(repository: repository);
});

// ═══════════════════════════════════════════════════════════════
// SCHEDULE PROVIDER — oddiy AsyncNotifier
// ═══════════════════════════════════════════════════════════════

class ScheduleState {
  final List<ScheduleModel> schedule;
  final bool isLoading;
  final String? error;
  final int selectedDay; // 1-6

  const ScheduleState({
    this.schedule = const [],
    this.isLoading = false,
    this.error,
    this.selectedDay = 1,
  });

  const ScheduleState.initial()
    : schedule = const [],
      isLoading = false,
      error = null,
      selectedDay = 1;

  ScheduleState copyWith({
    List<ScheduleModel>? schedule,
    bool? isLoading,
    String? error,
    int? selectedDay,
  }) {
    return ScheduleState(
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  /// Tanlangan kun uchun darslar (filtrlangan)
  List<ScheduleModel> get todaySchedule {
    return schedule.where((s) => s.dayOfWeek == selectedDay).toList()
      ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final AcademicRepository _repository;

  ScheduleNotifier({required AcademicRepository repository})
    : _repository = repository,
      super(const ScheduleState.initial());

  Future<void> loadSchedule(int childId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getSchedule(childId);

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (schedule) =>
          state = state.copyWith(schedule: schedule, isLoading: false),
    );
  }

  void selectDay(int day) {
    state = state.copyWith(selectedDay: day);
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) {
    final repository = ref.watch(academicRepositoryProvider);
    return ScheduleNotifier(repository: repository);
  },
);

// ═══════════════════════════════════════════════════════════════
// ASSIGNMENTS PROVIDER
// ═══════════════════════════════════════════════════════════════

// Sentinel value for null-aware copyWith
const _undefined = Object();

class AssignmentsState {
  final List<AssignmentModel> assignments;
  final AssignmentModel? selectedAssignment;
  final bool isLoading;
  final String? error;

  const AssignmentsState({
    this.assignments = const [],
    this.selectedAssignment,
    this.isLoading = false,
    this.error,
  });

  const AssignmentsState.initial()
    : assignments = const [],
      selectedAssignment = null,
      isLoading = false,
      error = null;

  AssignmentsState copyWith({
    List<AssignmentModel>? assignments,
    Object? selectedAssignment = _undefined,
    bool? isLoading,
    String? error,
  }) {
    return AssignmentsState(
      assignments: assignments ?? this.assignments,
      selectedAssignment: selectedAssignment == _undefined
          ? this.selectedAssignment
          : selectedAssignment as AssignmentModel?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AssignmentsNotifier extends StateNotifier<AssignmentsState> {
  final AcademicRepository _repository;

  AssignmentsNotifier({required AcademicRepository repository})
    : _repository = repository,
      super(const AssignmentsState.initial());

  Future<void> loadAssignments(int childId, {String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAssignments(childId, status: status);

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (assignments) =>
          state = state.copyWith(assignments: assignments, isLoading: false),
    );
  }

  Future<void> loadAssignmentDetails(int assignmentId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAssignmentDetails(assignmentId);

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (assignment) => state = state.copyWith(
        selectedAssignment: assignment,
        isLoading: false,
      ),
    );
  }

  Future<bool> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.submitAssignment(
      assignmentId,
      text: text,
      filePath: filePath,
    );

    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }
}

final assignmentsProvider =
    StateNotifierProvider<AssignmentsNotifier, AssignmentsState>((ref) {
      final repository = ref.watch(academicRepositoryProvider);
      return AssignmentsNotifier(repository: repository);
    });

// ═══════════════════════════════════════════════════════════════
// ATTENDANCE PROVIDER
// ═══════════════════════════════════════════════════════════════

class AttendanceState {
  final List<AttendanceModel> records;
  final AttendanceSummary? summary;
  final bool isLoading;
  final String? error;

  const AttendanceState({
    this.records = const [],
    this.summary,
    this.isLoading = false,
    this.error,
  });

  const AttendanceState.initial()
    : records = const [],
      summary = null,
      isLoading = false,
      error = null;

  AttendanceState copyWith({
    List<AttendanceModel>? records,
    Object? summary = _undefined,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      summary: summary == _undefined
          ? this.summary
          : summary as AttendanceSummary?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AcademicRepository _repository;

  AttendanceNotifier({required AcademicRepository repository})
    : _repository = repository,
      super(const AttendanceState.initial());

  /// Davomat va statistikani parallel yuklash
  Future<void> loadAttendance(int childId, {String? month}) async {
    state = state.copyWith(isLoading: true, error: null);

    final results = await Future.wait([
      _repository.getAttendance(childId, month: month),
      _repository.getAttendanceSummary(childId),
    ]);

    final recordsResult = results[0];
    final summaryResult = results[1];

    List<AttendanceModel> records = [];
    AttendanceSummary? summary;
    String? error;

    recordsResult.fold(
      (f) => error = f.message,
      (r) => records = r as List<AttendanceModel>,
    );

    summaryResult.fold(
      (f) => error ??= f.message,
      (s) => summary = s as AttendanceSummary,
    );

    state = state.copyWith(
      records: records,
      summary: summary,
      isLoading: false,
      error: error,
    );
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      final repository = ref.watch(academicRepositoryProvider);
      return AttendanceNotifier(repository: repository);
    });
