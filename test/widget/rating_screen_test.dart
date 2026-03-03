import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/data/models/rating_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/rating_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/rating/rating_screen.dart';

class MockRatingNotifier extends StateNotifier<RatingState> with Mock implements RatingNotifier {
  MockRatingNotifier(super.state);
}

void main() {
  late MockRatingNotifier mockRatingNotifier;

  final testChild = ChildModel(
    id: 1,
    fullName: 'Ali',
    className: '1A',
    classId: 10,
  );

  final testClassRating = [
    RatingModel(id: 1, studentName: 'Ali', rank: 1, totalScore: 100, isCurrent: true),
    RatingModel(id: 2, studentName: 'Vali', rank: 2, totalScore: 90),
    RatingModel(id: 3, studentName: 'Gani', rank: 3, totalScore: 80),
    RatingModel(id: 4, studentName: 'Sami', rank: 4, totalScore: 70),
    RatingModel(id: 5, studentName: 'Kari', rank: 5, totalScore: 60),
  ];

  final testSchoolRating = [
    RatingModel(id: 6, studentName: 'Bobur', rank: 1, totalScore: 150),
    RatingModel(id: 1, studentName: 'Ali', rank: 2, totalScore: 100, isCurrent: true),
  ];

  setUp(() {
    mockRatingNotifier = MockRatingNotifier(
      RatingState(
        classRating: testClassRating,
        schoolRating: testSchoolRating,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        ratingProvider.overrideWith((ref) => mockRatingNotifier),
        selectedChildProvider.overrideWithValue(testChild),
      ],
      child: const MaterialApp(
        home: RatingScreen(),
      ),
    );
  }

  group('RatingScreen Widget Tests', () {
    testWidgets('shows loading state correctly', (tester) async {
      mockRatingNotifier = MockRatingNotifier(
        const RatingState(isLoading: true, classRating: []),
      );
      when(() => mockRatingNotifier.loadClassRating(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders class rating correctly with podium', (tester) async {
      when(() => mockRatingNotifier.loadClassRating(10)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check Podium rendering
      expect(find.text('Reyting'), findsOneWidget);
      expect(find.text('Ali'), findsWidgets); // Podium & list
      expect(find.text('Vali'), findsOneWidget);
      expect(find.text('Gani'), findsOneWidget);

      // Check remaining list elements
      expect(find.text('Sami'), findsOneWidget);
      expect(find.text('Kari'), findsOneWidget);
      expect(find.text('70.0 ball'), findsOneWidget);
      
      verify(() => mockRatingNotifier.loadClassRating(10)).called(1);
    });

    testWidgets('switches to school rating on tab press', (tester) async {
      when(() => mockRatingNotifier.loadClassRating(10)).thenAnswer((_) async {});
      when(() => mockRatingNotifier.loadSchoolRating()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final schoolTab = find.text('Maktabda');
      await tester.tap(schoolTab);
      await tester.pumpAndSettle();

      expect(find.text('Bobur'), findsOneWidget);
      // Ali is rank 2 in school
      expect(find.text('150.0'), findsOneWidget); 

      verify(() => mockRatingNotifier.loadSchoolRating()).called(1);
    });

    testWidgets('shows "Ma\'lumot yo\'q" if rating is empty', (tester) async {
      mockRatingNotifier = MockRatingNotifier(
        const RatingState(classRating: [], isLoading: false),
      );
      when(() => mockRatingNotifier.loadClassRating(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text("Ma'lumot yo'q"), findsOneWidget);
    });
  });
}
