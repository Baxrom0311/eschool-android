import '../datasources/remote/menu_api.dart';
import '../models/menu_model.dart';
import 'base_repository.dart';

/// Menu (Taomnoma) Repozitoriyasi
class MenuRepository extends BaseRepository {
  final MenuApi _menuApi;

  MenuRepository({required MenuApi menuApi}) : _menuApi = menuApi;

  /// Bir kunlik taomnomani olish
  Future<List<MenuModel>> getDailyMenu({String? date, int? studentId}) =>
      _menuApi.getDailyMenu(date: date, studentId: studentId);

  /// Bir haftalik taomnomani olish
  Future<List<MenuModel>> getWeeklyMenu({String? weekStart, int? studentId}) =>
      _menuApi.getWeeklyMenu(weekStart: weekStart, studentId: studentId);
}
