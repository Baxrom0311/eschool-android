import '../datasources/remote/user_api.dart';
import '../models/child_model.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// User Repository — profil va farzandlar biznes logikasi
class UserRepository extends BaseRepository {
  final UserApi _userApi;

  UserRepository({required UserApi userApi}) : _userApi = userApi;

  /// Profil ma'lumotlarini olish
  Future<UserModel> getProfile() => _userApi.getProfile();

  /// Profilni yangilash
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) => _userApi.updateProfile(
    fullName: fullName,
    email: email,
    phone: phone,
    notificationsEnabled: notificationsEnabled,
  );

  /// Avatar yuklash
  Future<String> uploadAvatar(String filePath) => _userApi.uploadAvatar(filePath);

  /// Farzandlar ro'yxati
  Future<List<ChildModel>> getChildren() => _userApi.getChildren();

  /// Bitta farzand tafsilotlari
  Future<ChildModel> getChildDetails(int childId) => _userApi.getChildDetails(childId);

  /// Parol o'zgartirish
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) => _userApi.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );
}
