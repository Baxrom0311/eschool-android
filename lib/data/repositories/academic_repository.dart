import '../../core/utils/safe_api_call.dart';
import '../../core/localization/app_localizations.dart';
import '../datasources/remote/academic_api.dart';
import '../models/assignment_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/schedule_model.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Academic Repository — o'quv jarayoni biznes logikasi
class AcademicRepository {
  final AcademicApi _academicApi;

  AcademicRepository({required AcademicApi academicApi})
    : _academicApi = academicApi;

  // ─── Baholar ───

  Future<Either<Failure, List<GradeModel>>> getGrades(
    int childId, {
    int? quarter,
  }) => safeApiCall(
    () => _academicApi.getGrades(childId, quarter: quarter),
    errorMessage: AppLocalizations.current.gradesLoadFailed,
  );

  Future<Either<Failure, List<SubjectGradeSummary>>> getGradeSummary(
    int childId,
  ) => safeApiCall(
    () => _academicApi.getGradeSummary(childId),
    errorMessage: AppLocalizations.current.gradeSummaryLoadFailed,
  );

  // ─── Jadval ───

  Future<Either<Failure, List<ScheduleModel>>> getSchedule(int childId) =>
      safeApiCall(
        () => _academicApi.getSchedule(childId),
        errorMessage: AppLocalizations.current.scheduleLoadFailed,
      );

  // ─── Topshiriqlar ───

  Future<Either<Failure, List<AssignmentModel>>> getAssignments(
    int childId, {
    String? status,
    int page = 1,
  }) => safeApiCall(
    () => _academicApi.getAssignments(childId, status: status, page: page),
    errorMessage: AppLocalizations.current.assignmentsLoadFailed,
  );

  Future<Either<Failure, AssignmentModel>> getAssignmentDetails(
    int assignmentId, {
    required int childId,
  }) => safeApiCall(
    () => _academicApi.getAssignmentDetails(assignmentId, childId),
    errorMessage: AppLocalizations.current.assignmentDetailsLoadFailed,
  );

  Future<Either<Failure, void>> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) => safeApiCall(
    () => _academicApi.submitAssignment(
      assignmentId,
      text: text,
      filePath: filePath,
    ),
    errorMessage: AppLocalizations.current.assignmentSubmitFailed,
  );

  Future<Either<Failure, AttachmentModel>> uploadAssignmentFile(
    int assignmentId,
    String filePath,
  ) => safeApiCall(
    () => _academicApi.uploadAssignmentFile(assignmentId, filePath),
    errorMessage: AppLocalizations.current.assignmentUploadFailed,
  );

  // ─── Davomat ───

  Future<Either<Failure, List<AttendanceModel>>> getAttendance(
    int childId, {
    String? month,
  }) => safeApiCall(
    () => _academicApi.getAttendance(childId, month: month),
    errorMessage: AppLocalizations.current.attendanceLoadFailed,
  );

  Future<Either<Failure, AttendanceSummary>> getAttendanceSummary(
    int childId,
  ) => safeApiCall(
    () => _academicApi.getAttendanceSummary(childId),
    errorMessage: AppLocalizations.current.attendanceSummaryLoadFailed,
  );
}
