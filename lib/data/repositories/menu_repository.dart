import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/menu_api.dart';
import '../models/menu_model.dart';

/// Menu Repository
class MenuRepository {
  final MenuApi _menuApi;

  MenuRepository({required MenuApi menuApi}) : _menuApi = menuApi;

  Future<Either<Failure, List<MenuModel>>> getDailyMenu({
    String? date,
    int? studentId,
  }) async {
    try {
      final menu = await _menuApi.getDailyMenu(date: date, studentId: studentId);
      return Right(menu);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Menyuni yuklashda xatolik: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<MenuModel>>> getWeeklyMenu({
    String? weekStart,
    int? studentId,
  }) async {
    try {
      final menu = await _menuApi.getWeeklyMenu(
        weekStart: weekStart,
        studentId: studentId,
      );
      return Right(menu);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Menyuni yuklashda xatolik: ${e.toString()}'));
    }
  }
}
