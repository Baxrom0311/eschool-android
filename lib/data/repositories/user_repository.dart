import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/user_api.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';

/// User Repository — profil va farzandlar biznes logikasi
class UserRepository {
  final UserApi _userApi;

  UserRepository({required UserApi userApi}) : _userApi = userApi;

  /// Profil ma'lumotlarini olish
  Future<Either<Failure, UserModel>> getProfile() async {
    try {
      final user = await _userApi.getProfile();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Profilni yuklashda xatolik: ${e.toString()}'));
    }
  }

  /// Profilni yangilash
  Future<Either<Failure, UserModel>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) async {
    try {
      final user = await _userApi.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        notificationsEnabled: notificationsEnabled,
      );
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Profilni yangilashda xatolik: ${e.toString()}'));
    }
  }

  /// Avatar yuklash
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final avatarUrl = await _userApi.uploadAvatar(filePath);
      return Right(avatarUrl);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Rasm yuklashda xatolik: ${e.toString()}'));
    }
  }

  /// Farzandlar ro'yxati
  Future<Either<Failure, List<ChildModel>>> getChildren() async {
    try {
      final children = await _userApi.getChildren();
      return Right(children);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Farzandlarni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  /// Bitta farzand tafsilotlari
  Future<Either<Failure, ChildModel>> getChildDetails(int childId) async {
    try {
      final child = await _userApi.getChildDetails(childId);
      return Right(child);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Ma\'lumot yuklashda xatolik: ${e.toString()}'));
    }
  }
}
