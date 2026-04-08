import '../datasources/remote/academic_api.dart';
import '../models/assignment_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/schedule_model.dart';
import 'base_repository.dart';

/// Academic Repository — o'quv jarayoni biznes logikasi
class AcademicRepository extends BaseRepository {
  final AcademicApi _academicApi;

  AcademicRepository({required AcademicApi academicApi})
    : _academicApi = academicApi;

  // ─── Baholar ───
  Future<List<GradeModel>> getGrades(int childId, {int? quarter}) =>
      _academicApi.getGrades(childId, quarter: quarter);

  Future<List<SubjectGradeSummary>> getGradeSummary(int childId) =>
      _academicApi.getGradeSummary(childId);

  // ─── Jadval ───
  Future<List<ScheduleModel>> getSchedule(int childId) =>
      _academicApi.getSchedule(childId);

  // ─── Topshiriqlar ───
  Future<List<AssignmentModel>> getAssignments(
    int childId, {
    String? status,
    int page = 1,
  }) => _academicApi.getAssignments(childId, status: status, page: page);

  Future<AssignmentModel> getAssignmentDetails(
    int assignmentId, {
    required int childId,
  }) => _academicApi.getAssignmentDetails(assignmentId, childId);

  Future<void> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) => _academicApi.submitAssignment(
    assignmentId,
    text: text,
    filePath: filePath,
  );

  Future<AttachmentModel> uploadAssignmentFile(
    int assignmentId,
    String filePath,
  ) => _academicApi.uploadAssignmentFile(assignmentId, filePath);

  // ─── Davomat ───
  Future<List<AttendanceModel>> getAttendance(int childId, {String? month}) =>
      _academicApi.getAttendance(childId, month: month);

  Future<AttendanceSummary> getAttendanceSummary(int childId) =>
      _academicApi.getAttendanceSummary(childId);
}
