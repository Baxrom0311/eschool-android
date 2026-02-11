import 'dart:async';

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
    state = const AsyncValue.loading();

    final repository = ref.read(academicRepositoryProvider);
    final targetQuarter = quarter ?? state.value?.selectedQuarter ?? 1;

    state = await AsyncValue.guard(() async {
      // Parallel fetch
      final (gradesResult, summaryResult) = await (
        repository.getGrades(childId, quarter: targetQuarter),
        repository.getGradeSummary(childId),
      ).wait;

      // Throw/Unwrap errors if any failure occurred
      final grades = gradesResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      final summary = summaryResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      return GradesData(
        grades: grades,
        summary: summary,
        selectedQuarter: targetQuarter,
      );
    });
  }

  void selectQuarter(int quarter) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(selectedQuarter: quarter));
      // Note: Typically you'd re-fetch here if the data depends on the quarter,
      // but the original code just updated the state.
      // If re-fetch is needed, call loadGrades(childId, quarter: quarter).
    }
  }
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

  const ScheduleData({
    this.fullSchedule = const [],
    this.selectedDay = 1,
  });

  List<ScheduleModel> get todaySchedule {
    return fullSchedule
        .where((s) => s.dayOfWeek == selectedDay)
        .toList()
      ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
  }
}

class ScheduleNotifier extends AutoDisposeAsyncNotifier<ScheduleData> {
  @override
  FutureOr<ScheduleData> build() {
    return const ScheduleData();
  }

  Future<void> loadSchedule(int childId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(academicRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final result = await repository.getSchedule(childId);
      return result.fold(
        (l) => throw Exception(l.message),
        (r) => ScheduleData(
          fullSchedule: r,
          selectedDay: DateTime.now().weekday,
        ),
      );
    });
  }

  void selectDay(int day) {
    if (state.value != null) {
      final currentData = state.value!;
      state = AsyncValue.data(
        ScheduleData(
          fullSchedule: currentData.fullSchedule,
          selectedDay: day,
        ),
      );
    }
  }
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

  const AssignmentsData({
    this.assignments = const [],
    this.selectedAssignment,
  });
}

class AssignmentsNotifier extends AutoDisposeAsyncNotifier<AssignmentsData> {
  @override
  FutureOr<AssignmentsData> build() {
    return const AssignmentsData();
  }

  Future<void> loadAssignments(int childId, {String? status}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(academicRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final result = await repository.getAssignments(childId, status: status);
      return result.fold(
        (l) => throw Exception(l.message),
        (r) => AssignmentsData(assignments: r),
      );
    });
  }

  Future<void> loadAssignmentDetails(int assignmentId) async {
    // We don't want to replace the whole list state with loading if we are just viewing details
    // But for simplicity in this refactor, we usually use a separate provider for details
    // or we treat this as a mutation.
    // For now, let's keep it simple: detailed view loading might be handled separately or here.
    final previousState = state.value;

    final repository = ref.read(academicRepositoryProvider);
    final result = await repository.getAssignmentDetails(assignmentId);

    result.fold(
      (l) {
        // Handle error (maybe show toast), don't invalidate list
      },
      (details) {
        if (previousState != null) {
          state = AsyncValue.data(
            AssignmentsData(
              assignments: previousState.assignments,
              selectedAssignment: details,
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
    state = const AsyncValue.loading();
    final repository = ref.read(academicRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final (recordsResult, summaryResult) = await (
        repository.getAttendance(childId, month: month),
        repository.getAttendanceSummary(childId),
      ).wait;

      final records = recordsResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      final summary = summaryResult.fold(
        (l) => throw Exception(l.message),
        (r) => r,
      );

      return AttendanceData(records: records, summary: summary);
    });
  }
}

final attendanceProvider =
    AsyncNotifierProvider.autoDispose<AttendanceNotifier, AttendanceData>(
      AttendanceNotifier.new,
    );
