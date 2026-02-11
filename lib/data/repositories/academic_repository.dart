import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/academic_api.dart';
import '../models/assignment_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/schedule_model.dart';

/// Academic Repository — o'quv jarayoni biznes logikasi
class AcademicRepository {
  final AcademicApi _academicApi;

  AcademicRepository({required AcademicApi academicApi})
    : _academicApi = academicApi;

  // ─── Baholar ───

  Future<Either<Failure, List<GradeModel>>> getGrades(
    int childId, {
    int? quarter,
  }) async {
    try {
      final grades = await _academicApi.getGrades(childId, quarter: quarter);
      return Right(grades);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Baholarni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<SubjectGradeSummary>>> getGradeSummary(
    int childId,
  ) async {
    try {
      final summary = await _academicApi.getGradeSummary(childId);
      return Right(summary);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Xatolik: ${e.toString()}'));
    }
  }

  // ─── Jadval ───

  Future<Either<Failure, List<ScheduleModel>>> getSchedule(int childId) async {
    try {
      final schedule = await _academicApi.getSchedule(childId);
      return Right(schedule);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Jadvalni yuklashda xatolik: ${e.toString()}'));
    }
  }

  // ─── Topshiriqlar ───

  Future<Either<Failure, List<AssignmentModel>>> getAssignments(
    int childId, {
    String? status,
    int page = 1,
  }) async {
    try {
      final assignments = await _academicApi.getAssignments(
        childId,
        status: status,
        page: page,
      );
      return Right(assignments);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Topshiriqlarni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, AssignmentModel>> getAssignmentDetails(
    int assignmentId,
  ) async {
    try {
      final assignment = await _academicApi.getAssignmentDetails(assignmentId);
      return Right(assignment);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Xatolik: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> submitAssignment(
    int assignmentId, {
    String? text,
    String? filePath,
  }) async {
    try {
      await _academicApi.submitAssignment(
        assignmentId,
        text: text,
        filePath: filePath,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Topshiriqni yuborishda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, AttachmentModel>> uploadAssignmentFile(
    int assignmentId,
    String filePath,
  ) async {
    try {
      final attachment = await _academicApi.uploadAssignmentFile(
        assignmentId,
        filePath,
      );
      return Right(attachment);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Fayl yuklashda xatolik: ${e.toString()}'));
    }
  }

  // ─── Davomat ───

  Future<Either<Failure, List<AttendanceModel>>> getAttendance(
    int childId, {
    String? month,
  }) async {
    try {
      final attendance = await _academicApi.getAttendance(
        childId,
        month: month,
      );
      return Right(attendance);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Davomatni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, AttendanceSummary>> getAttendanceSummary(
    int childId,
  ) async {
    try {
      final summary = await _academicApi.getAttendanceSummary(childId);
      return Right(summary);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Xatolik: ${e.toString()}'));
    }
  }
}
