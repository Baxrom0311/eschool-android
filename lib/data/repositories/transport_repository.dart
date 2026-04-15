import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/transport_model.dart';
import 'base_repository.dart';

class TransportRepository extends BaseRepository {
  final DioClient _dioClient;

  TransportRepository(this._dioClient);

  /// Fetch the live location and route info for a specific student's designated bus.
  Future<BusRouteInfoModel> getStudentBusLocation(int studentId) async {
    return safeCall<BusRouteInfoModel>(
      () => _dioClient.dio.get(
        '/api/v1/transport/location',
        queryParameters: {'student_id': studentId},
      ),
      (data) => BusRouteInfoModel.fromJson(data),
    );
  }
}
