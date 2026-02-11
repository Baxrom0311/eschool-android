import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/safe_api_call.dart';
import '../datasources/remote/menu_api.dart';
import '../models/menu_model.dart';

/// Menu Repository
class MenuRepository {
  final MenuApi _menuApi;

  MenuRepository({required MenuApi menuApi}) : _menuApi = menuApi;

  Future<Either<Failure, List<MenuModel>>> getDailyMenu({
    String? date,
    int? studentId,
  }) =>
      safeApiCall(
        () => _menuApi.getDailyMenu(date: date, studentId: studentId),
        errorMessage: 'Menyuni yuklashda xatolik',
      );

  Future<Either<Failure, List<MenuModel>>> getWeeklyMenu({
    String? weekStart,
    int? studentId,
  }) =>
      safeApiCall(
        () => _menuApi.getWeeklyMenu(weekStart: weekStart, studentId: studentId),
        errorMessage: 'Haftalik menyuni yuklashda xatolik',
      );
}
