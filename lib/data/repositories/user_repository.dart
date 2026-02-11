import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/safe_api_call.dart';
import '../datasources/remote/user_api.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';

/// User Repository — profil va farzandlar biznes logikasi
class UserRepository {
  final UserApi _userApi;

  UserRepository({required UserApi userApi}) : _userApi = userApi;

  /// Profil ma'lumotlarini olish
  Future<Either<Failure, UserModel>> getProfile() => safeApiCall(
        () => _userApi.getProfile(),
        errorMessage: 'Profilni yuklashda xatolik',
      );

  /// Profilni yangilash
  Future<Either<Failure, UserModel>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) =>
      safeApiCall(
        () => _userApi.updateProfile(
          fullName: fullName,
          email: email,
          phone: phone,
          notificationsEnabled: notificationsEnabled,
        ),
        errorMessage: 'Profilni yangilashda xatolik',
      );

  /// Avatar yuklash
  Future<Either<Failure, String>> uploadAvatar(String filePath) => safeApiCall(
        () => _userApi.uploadAvatar(filePath),
        errorMessage: 'Rasm yuklashda xatolik',
      );

  /// Farzandlar ro'yxati
  Future<Either<Failure, List<ChildModel>>> getChildren() => safeApiCall(
        () => _userApi.getChildren(),
        errorMessage: 'Farzandlarni yuklashda xatolik',
      );

  /// Bitta farzand tafsilotlari
  Future<Either<Failure, ChildModel>> getChildDetails(int childId) =>
      safeApiCall(
        () => _userApi.getChildDetails(childId),
        errorMessage: 'Ma\'lumot yuklashda xatolik',
      );
}
