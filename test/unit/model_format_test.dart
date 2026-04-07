import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/menu_model.dart';
import 'package:parent_school_app/data/models/payment_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';

void main() {
  setUp(() {
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
  });

  group('ScheduleModel markText', () {
    test('returns grade value in grade mode', () {
      const model = ScheduleModel(
        id: 1,
        subjectName: 'Matematika',
        teacherName: 'Teacher',
        startTime: '08:00',
        endTime: '08:45',
        dayOfWeek: 1,
        lessonNumber: 1,
        markValue: 5,
        markMode: 'grade',
      );

      expect(model.markText, '5');
    });

    test('returns coin suffix in coin mode', () {
      const model = ScheduleModel(
        id: 1,
        subjectName: 'Matematika',
        teacherName: 'Teacher',
        startTime: '08:00',
        endTime: '08:45',
        dayOfWeek: 1,
        lessonNumber: 1,
        markValue: 12,
        markMode: 'coin',
      );

      expect(model.markText, '12 coin');
    });
  });

  group('MenuModel mealTypeText', () {
    test('supports afternoon tea and dinner texts', () {
      const tea = MenuModel(
        id: 1,
        date: '2026-02-21',
        mealType: MealType.afternoonTea,
      );
      const dinner = MenuModel(
        id: 2,
        date: '2026-02-21',
        mealType: MealType.dinner,
      );

      expect(tea.mealTypeText, 'Poldnik');
      expect(dinner.mealTypeText, 'Kechki ovqat');
    });

    test('uses current locale for meal type text', () {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

      const breakfast = MenuModel(
        id: 3,
        date: '2026-02-21',
        mealType: MealType.breakfast,
      );

      expect(breakfast.mealTypeText, 'Breakfast');
    });
  });

  group('PaymentModel formattedAmount', () {
    test('keeps decimal part when present', () {
      const model = PaymentModel(
        id: 1,
        amount: 150000.5,
        status: PaymentStatus.completed,
        method: PaymentMethod.payme,
        createdAt: '2026-02-21',
      );

      expect(model.formattedAmount, '150 000.50 so\'m');
    });

    test('hides .00 when amount is integer', () {
      const model = PaymentModel(
        id: 1,
        amount: 150000,
        status: PaymentStatus.completed,
        method: PaymentMethod.payme,
        createdAt: '2026-02-21',
      );

      expect(model.formattedAmount, '150 000 so\'m');
    });
  });

  group('GradeModel gradeTypeText', () {
    test('uses current locale for grade type labels', () {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

      const model = GradeModel(
        id: 1,
        subjectName: 'Math',
        grade: 5,
        gradeType: 'homework',
        createdAt: '2026-02-21',
      );

      expect(model.gradeTypeText, 'Homework');
    });
  });
}
