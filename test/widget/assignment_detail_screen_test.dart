import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/presentation/screens/academics/assignment_detail_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('uz');
  });

  testWidgets('assignment detail screen renders localized labels', (
    tester,
  ) async {
    const assignment = AssignmentModel(
      id: 0,
      title: 'Algebra vazifasi',
      description: '1-5 mashqlarni yeching',
      subjectName: 'Algebra',
      teacherName: 'Domla',
      status: AssignmentStatus.pending,
      dueDate: '2026-04-10',
      createdAt: '2026-04-01',
      attachments: [
        AttachmentModel(name: 'topshiriq.pdf', url: '/files/topshiriq.pdf'),
      ],
      submittedFiles: [
        AttachmentModel(
          name: 'javob.docx',
          url: '/files/javob.docx',
          fileSize: 2048,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('uz'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AssignmentDetailScreen(assignment: assignment),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vazifa tafsilotlari'), findsOneWidget);
    expect(find.textContaining('Topshirish muddati:'), findsOneWidget);
    expect(find.text('Kutilmoqda'), findsOneWidget);
    expect(find.text('O\'qituvchi fayllari'), findsOneWidget);
    expect(find.text('Yuborilgan fayllar'), findsOneWidget);
    expect(find.text('Fayl tanlash'), findsOneWidget);
    expect(find.text('Yuborish'), findsOneWidget);
  });
}
