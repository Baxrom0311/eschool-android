import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock UserRepository
class MockUserRepository implements UserRepository {
  bool shouldReturnError = false;

  @override
  Future<UserModel> getProfile() async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Profile load failed');
    }
    return const UserModel(
      id: 1,
      fullName: 'Test Parent',
      phone: '+998901234567',
      children: [
        ChildModel(
          id: 101,
          fullName: 'Child One',
          className: '5-A',
          classId: 5,
        ),
        ChildModel(
          id: 102,
          fullName: 'Child Two',
          className: '3-B',
          classId: 3,
        ),
      ],
    );
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Update failed');
    }
    return UserModel(
      id: 1,
      fullName: fullName ?? 'Test Parent',
      phone: phone ?? '+998901234567',
      email: email,
      notificationsEnabled: notificationsEnabled ?? true,
      children: const [],
    );
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Upload failed');
    }
    return 'https://example.com/avatar.jpg';
  }

  @override
  Future<ChildModel> getChildDetails(int childId) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Details load failed');
    }
    return ChildModel(
      id: childId,
      fullName: 'Child $childId',
      className: '5-A',
      classId: 5,
    );
  }

  @override
  Future<List<ChildModel>> getChildren() async => const [];

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Password change failed');
    }
  }

  @override
  Future<T> safeCall<T>(dynamic call, dynamic mapper) async =>
      throw UnimplementedError();
  @override
  Future<List<T>> safeCallList<T>(
    dynamic call,
    dynamic mapper, {
    String? listKey,
  }) async => throw UnimplementedError();
  @override
  Future<T> safeExecute<T>(dynamic call) async => throw UnimplementedError();
}

void main() {
  late UserNotifier userNotifier;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    userNotifier = UserNotifier(repository: mockRepository);
  });

  group('UserNotifier Tests', () {
    test('Initial state should be correct', () {
      expect(userNotifier.state.isLoading, false);
      expect(userNotifier.state.user, null);
    });

    test(
      'loadProfile success should update state with user and children',
      () async {
        await userNotifier.loadProfile();

        expect(userNotifier.state.isLoading, false);
        expect(userNotifier.state.user?.fullName, 'Test Parent');
        expect(userNotifier.state.children.length, 2);
        expect(userNotifier.state.selectedChild?.id, 101);
        expect(userNotifier.state.error, null);
      },
    );

    test('loadProfile failure should update state with error', () async {
      mockRepository.shouldReturnError = true;
      await userNotifier.loadProfile();

      expect(userNotifier.state.isLoading, false);
      expect(userNotifier.state.error, 'ServerException: Profile load failed');
    });

    test('selectChild should update selectedChild in state', () async {
      await userNotifier.loadProfile();

      final child2 = userNotifier.state.children[1];
      userNotifier.selectChild(child2);

      expect(userNotifier.state.selectedChild?.id, 102);
    });

    test('updateProfile success should update user info', () async {
      await userNotifier.updateProfile(fullName: 'Updated Name');

      expect(userNotifier.state.isLoading, false);
      expect(userNotifier.state.user?.fullName, 'Updated Name');
    });

    test('uploadAvatar success should update avatar url', () async {
      await userNotifier.loadProfile();

      await userNotifier.uploadAvatar('/path/to/image.jpg');

      expect(userNotifier.state.isLoading, false);
      expect(
        userNotifier.state.user?.avatarUrl,
        'https://example.com/avatar.jpg',
      );
    });
  });
}
