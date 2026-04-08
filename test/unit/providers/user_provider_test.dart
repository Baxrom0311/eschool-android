import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUp(() async {
    mockRepository = MockUserRepository();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(mockRepository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('UserNotifier', () {
    const tChild = ChildModel(
      id: 1,
      fullName: 'John Jr',
      className: '5A',
      classId: 10,
    );

    const tUser = UserModel(
      id: 1,
      fullName: 'John Doe',
      phone: '+998901234567',
      role: 'parent',
      balance: 150000,
      monthlyFee: 100000,
      children: [tChild],
    );

    test('initial state is correct', () {
      final container = createContainer();
      final state = container.read(userProvider);

      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.children, isEmpty);
      expect(state.selectedChild, isNull);
      expect(state.error, isNull);
    });

    test(
      'loadProfile updates state and resolves selected child on success',
      () async {
        final container = createContainer();
        when(() => mockRepository.getProfile()).thenAnswer((_) async => tUser);

        final future = container.read(userProvider.notifier).loadProfile();
        expect(container.read(userProvider).isLoading, true);

        await future;

        final state = container.read(userProvider);
        expect(state.isLoading, false);
        expect(state.user, tUser);
        expect(state.children, [tChild]);
        expect(state.selectedChild, tChild);
        expect(state.error, isNull);
      },
    );

    test('loadProfile handles ServerException appropriately', () async {
      final container = createContainer();
      when(
        () => mockRepository.getProfile(),
      ).thenThrow(const ServerException(message: 'Server error'));

      await container.read(userProvider.notifier).loadProfile();

      final state = container.read(userProvider);
      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, 'ServerException: Server error');
    });

    test('selectChild updates selectedChild in state', () async {
      final container = createContainer();
      when(() => mockRepository.getProfile()).thenAnswer((_) async => tUser);

      await container.read(userProvider.notifier).loadProfile();

      const tChild2 = ChildModel(
        id: 2,
        fullName: 'Jane Doe',
        className: '3B',
        classId: 8,
      );

      // Suppose we had a second child, we manually select it
      container.read(userProvider.notifier).selectChild(tChild2);

      final state = container.read(userProvider);
      expect(state.selectedChild, tChild2);
    });
  });
}
