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
import 'package:parent_school_app/presentation/screens/chat/chat_room_screen.dart';

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
        home: ChatRoomScreen(
          chatData: {
            'id': 1,
            'name': 'Ali Valiyev',
            'isOnline': true,
          },
        ),
      ),
    );
  }

  group('ChatRoomScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final completer = Completer<Either<Failure, List<MessageModel>>>();
      when(() => mockChatRepository.getMessages(1, page: any(named: 'page'))).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows messages list when loaded', (WidgetTester tester) async {
      final tMessages = [
        const MessageModel(
          id: 1,
          content: 'Salom ustoz',
          type: MessageType.text,
          senderId: 10,
          senderName: 'Ota',
          isMine: true,
          createdAt: '2023-11-20T10:00:00.000000Z',
        ),
      ];
      when(() => mockChatRepository.getMessages(1, page: any(named: 'page')))
          .thenAnswer((_) async => Right(tMessages));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ali Valiyev'), findsOneWidget);
      expect(find.text('Onlayn'), findsOneWidget);
      expect(find.text('Salom ustoz'), findsOneWidget);
    });

    testWidgets('sends a message and clears textfield', (WidgetTester tester) async {
      when(() => mockChatRepository.getMessages(1, page: any(named: 'page')))
          .thenAnswer((_) async => const Right([]));
          
      final tMessage = const MessageModel(
        id: 2,
        content: 'Yangi xabar',
        type: MessageType.text,
        senderId: 10,
        senderName: 'Ota',
        isMine: true,
        createdAt: '2023-11-20T10:05:00.000000Z',
      );
          
      when(() => mockChatRepository.sendMessage(1, content: 'Yangi xabar'))
          .thenAnswer((_) async => Right(tMessage));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find textfield and enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Yangi xabar');
      await tester.pumpAndSettle();

      // Find send button
      final sendButton = find.byIcon(Icons.send_rounded);
      await tester.tap(sendButton);
      
      // We must mock successful send otherwise it returns error
      await tester.pumpAndSettle();

      expect(find.text('Yangi xabar'), findsOneWidget);
      // TextField should be cleared
      expect(tester.widget<TextField>(textField).controller?.text, isEmpty);
    });
  });
}
