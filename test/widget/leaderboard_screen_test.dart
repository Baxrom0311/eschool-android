import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/badge_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/leaderboard_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/leaderboard/leaderboard_screen.dart';

class MockLeaderboardNotifier extends StateNotifier<LeaderboardState>
    with Mock
    implements LeaderboardNotifier {
  MockLeaderboardNotifier(super.state);
}

void main() {
  late MockLeaderboardNotifier mockLeaderboardNotifier;

  const testChild = ChildModel(
    id: 1,
    fullName: 'Ali',
    className: '5-A',
    classId: 10,
  );

  setUp(() {
    mockLeaderboardNotifier = MockLeaderboardNotifier(
      const LeaderboardState(
        coins: 120,
        myBadges: [
          BadgeModel(
            id: 1,
            name: 'Faol o\'quvchi',
            description: 'Top badge',
            category: 'academic',
            icon: '🏆',
          ),
        ],
        availableBadges: [
          BadgeModel(
            id: 2,
            name: 'Yangi nishon',
            description: 'Locked badge',
            category: 'general',
            icon: '⭐',
          ),
        ],
        classRanking: [
          {'rank': 1, 'name': 'Ali', 'xp': 300, 'level': 5},
          {'rank': 2, 'name': 'Vali', 'xp': 280, 'level': 4},
          {'rank': 3, 'name': 'Gani', 'xp': 260, 'level': 4},
          {'rank': 4, 'name': 'Sami', 'xp': 220, 'level': 3},
        ],
        globalRanking: [
          {'rank': 1, 'name': 'Bobur', 'xp': 500, 'level': 8},
        ],
        classRank: 1,
        globalRank: 4,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    when(() => mockLeaderboardNotifier.loadData(1)).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [
        leaderboardProvider.overrideWith((ref) => mockLeaderboardNotifier),
        selectedChildProvider.overrideWithValue(testChild),
      ],
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LeaderboardScreen(),
      ),
    );
  }

  testWidgets('renders ranking and badges tab content', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Liderlar jadvali'), findsOneWidget);
    expect(find.text('Ali'), findsWidgets);

    await tester.tap(find.text('Nishonlar'));
    await tester.pumpAndSettle();

    expect(find.text('120 tanga'), findsOneWidget);
    expect(find.text('Faol o\'quvchi'), findsOneWidget);
    verify(() => mockLeaderboardNotifier.loadData(1)).called(1);
  });
}
