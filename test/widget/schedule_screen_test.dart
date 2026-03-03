import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/academics/schedule_screen.dart';
import 'package:parent_school_app/presentation/widgets/schedule/schedule_card.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAcademicRepository mockAcademicRepository;

  setUpAll(() async {
    await initializeDateFormatting('uz', null);
  });

  setUp(() async {
    mockUserRepository = MockUserRepository();
    mockAcademicRepository = MockAcademicRepository();

    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();

    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    final tUser = UserModel(id: 1, fullName: 'John Doe', phone: '+998901234567', children: [tChild]);
    when(() => mockUserRepository.getProfile()).thenAnswer((_) async => Right(tUser));
  });

  Widget createWidgetUnderTest() {
    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    return ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        academicRepositoryProvider.overrideWithValue(mockAcademicRepository),
        selectedChildProvider.overrideWithValue(tChild),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: ScheduleScreen(),
      ),
    );
  }

  group('ScheduleScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final completer = Completer<Either<Failure, List<ScheduleModel>>>();
      when(() => mockAcademicRepository.getSchedule(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no schedule exists', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getSchedule(any())).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Darslar mavjud emas'), findsOneWidget);
    });

    testWidgets('shows schedule items based on selected day', (WidgetTester tester) async {
      final todayWeekday = DateTime.now().weekday;
      final List<ScheduleModel> tSchedule = [
        ScheduleModel(
          id: 1,
          subjectName: 'Fizika',
          teacherName: 'Domla',
          startTime: '08:00',
          endTime: '08:45',
          dayOfWeek: todayWeekday,
          roomNumber: '101',
          lessonNumber: 1,
          markValue: 5,
          markMode: 'grade',
        ),
      ];
      when(() => mockAcademicRepository.getSchedule(any())).thenAnswer((_) async => Right(tSchedule));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Dars jadvali'), findsOneWidget);
      expect(find.text('Fizika'), findsOneWidget);
      expect(find.textContaining('101'), findsWidgets); // Contains room logic sometimes prefixes strings like Xona
      expect(find.text('Domla'), findsOneWidget);
      expect(find.byType(ScheduleCard), findsOneWidget);
    });

    testWidgets('shows error state when API fails', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getSchedule(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Tarmoq xatosi')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Xatolik: Exception: Tarmoq xatosi'), findsOneWidget);
    });
  });
}
