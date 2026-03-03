import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/datasources/remote/rating_api.dart';
import 'package:parent_school_app/data/datasources/remote/notification_api.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';
import 'package:parent_school_app/data/repositories/menu_repository.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/presentation/providers/chat_provider.dart';
import 'package:parent_school_app/presentation/providers/menu_provider.dart';
import 'package:parent_school_app/presentation/providers/notification_provider.dart';
import 'package:parent_school_app/presentation/providers/rating_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/home/home_screen.dart';
import 'package:parent_school_app/data/models/rating_model.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockAcademicRepository extends Mock implements AcademicRepository {}
class MockMenuRepository extends Mock implements MenuRepository {}
class MockChatRepository extends Mock implements ChatRepository {}
class MockRatingApi extends Mock implements RatingApi {}
class MockNotificationApi extends Mock implements NotificationApi {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAcademicRepository mockAcademicRepository;
  late MockMenuRepository mockMenuRepository;
  late MockChatRepository mockChatRepository;
  late MockRatingApi mockRatingApi;
  late MockNotificationApi mockNotificationApi;

  setUp(() async {
    await initializeDateFormatting();
    
    mockUserRepository = MockUserRepository();
    mockAcademicRepository = MockAcademicRepository();
    mockMenuRepository = MockMenuRepository();
    mockChatRepository = MockChatRepository();
    mockRatingApi = MockRatingApi();
    mockNotificationApi = MockNotificationApi();

    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
    
    // Setup generic mock responses
    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    final tUser = UserModel(id: 1, fullName: 'John Doe', phone: '+998901234567', children: [tChild]);
    
    when(() => mockUserRepository.getProfile()).thenAnswer((_) async => Right(tUser));
    final tRating = const RatingModel(id: 1, studentName: 'Test', rank: 1, totalScore: 10.0, averageGrade: 5.0, isCurrent: true);
    
    when(() => mockAcademicRepository.getGrades(any(), quarter: any(named: 'quarter'))).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getGrades(any())).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getSchedule(any())).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getAssignments(any(), status: any(named: 'status'), page: any(named: 'page'))).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getAssignments(any())).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month'))).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getAttendance(any())).thenAnswer((_) async => const Right([]));
    
    when(() => mockMenuRepository.getDailyMenu(date: any(named: 'date'), studentId: any(named: 'studentId'))).thenAnswer((_) async => const Right([]));
    when(() => mockMenuRepository.getDailyMenu()).thenAnswer((_) async => const Right([]));
    
    when(() => mockRatingApi.getChildRating(any())).thenAnswer((_) async => tRating);
    when(() => mockNotificationApi.getNotifications(page: any(named: 'page'))).thenAnswer((_) async => []);
    when(() => mockChatRepository.getConversations()).thenAnswer((_) async => const Right([]));
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        academicRepositoryProvider.overrideWithValue(mockAcademicRepository),
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        chatRepositoryProvider.overrideWithValue(mockChatRepository),
        ratingApiProvider.overrideWithValue(mockRatingApi),
        notificationApiProvider.overrideWithValue(mockNotificationApi),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen renders bottom navigation and dashboard aggregations', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Bottom Navigation items
      expect(find.text('Asosiy'), findsOneWidget);
      expect(find.text('Ta\'lim'), findsOneWidget);
      expect(find.text('Ovqat'), findsOneWidget);
      expect(find.text('To\'lov'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Verify Dashboard aggregations (widgets within _HomeTabScreen)
      // Since it requires icons or specific texts to verify, we check typical texts
      expect(find.text('Davomat'), findsWidgets); // AttendanceCard usually shows it
      expect(find.text('O\'rtacha baho'), findsWidgets); // AcademicStats usually shows GPA logic
      expect(find.text('Bugungi Darslar'), findsWidgets); // Schedule list title
      expect(find.text('Bugungi Tushlik'), findsWidgets); // DailyMenuCard
    });
  });
}
