import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/chat_model.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';
import 'package:parent_school_app/presentation/providers/chat_provider.dart';
import 'package:parent_school_app/presentation/screens/chat/chat_list_screen.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;

  setUp(() async {
    mockChatRepository = MockChatRepository();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        chatRepositoryProvider.overrideWithValue(mockChatRepository),
      ],
      child: const MaterialApp(
        home: ChatListScreen(),
      ),
    );
  }

  group('ChatListScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final completer = Completer<Either<Failure, List<ConversationModel>>>();
      when(() => mockChatRepository.getConversations()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state behavior when list is empty', (WidgetTester tester) async {
      when(() => mockChatRepository.getConversations()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows conversations when loaded', (WidgetTester tester) async {
      final tConversations = [
        const ConversationModel(
          id: 1,
          participantName: 'Ali Valiyev',
          lastMessage: 'Salom ustoz',
          unreadCount: 2,
        ),
      ];
      when(() => mockChatRepository.getConversations())
          .thenAnswer((_) async => Right(tConversations));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ali Valiyev'), findsOneWidget);
      expect(find.text('Salom ustoz'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Unread count badge
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('shows error state when API fails', (WidgetTester tester) async {
      when(() => mockChatRepository.getConversations())
          .thenAnswer((_) async => const Left(ServerFailure('Tarmoq xatosi')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tarmoq xatosi'), findsOneWidget);
    });
  });
}
