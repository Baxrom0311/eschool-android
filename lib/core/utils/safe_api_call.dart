import 'package:dartz/dartz.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Barcha repository metodlari uchun umumiy xatolik qayta ishlash wrapper.
///
/// Bu helper barcha exception → failure mapping logikasini markazlashtiradi
/// va repository larda takrorlanuvchi try/catch boilerplate ni yo'q qiladi.
///
/// Foydalanish:
/// ```dart
/// Future<Either<Failure, UserModel>> getProfile() {
///   return safeApiCall(
///     () => _userApi.getProfile(),
///     errorMessage: 'Profilni yuklashda xatolik',
///   );
/// }
/// ```
Future<Either<Failure, T>> safeApiCall<T>(
  Future<T> Function() call, {
  String errorMessage = 'Kutilmagan xatolik',
}) async {
  try {
    final result = await call();
    return Right(result);
  } on AuthException catch (e) {
    return Left(AuthFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message, e.errors));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('$errorMessage: ${e.toString()}'));
  }
}
