import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/lms_model.dart';
import 'base_repository.dart';

class LmsRepository extends BaseRepository {
  final DioClient _dioClient;

  LmsRepository(this._dioClient);

  /// Get student's enrolled courses
  Future<List<CourseModel>> getStudentCourses(int studentId) async {
    return safeCallList<CourseModel>(
      () => _dioClient.dio.get('/api/v1/lms/courses', queryParameters: {'student_id': studentId}),
      (data) => CourseModel.fromJson(data),
    );
  }
}
