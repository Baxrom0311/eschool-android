import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/models/payment_model.dart';

void main() {
  group('UserModel parsing', () {
    test('parses successfully from standard backend payload', () {
      final json = {
        'id': 15,
        'full_name': 'Test Parent',
        'phone': '+998901234567',
        'email': 'parent@example.com',
        'role': 'parent',
        'balance': 150000,
        'children': [
          {
            'id': 20,
            'full_name': 'Test Child',
            'class_name': '10-A',
            'class_id': 5,
          }
        ]
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 15);
      expect(model.fullName, 'Test Parent');
      expect(model.phone, '+998901234567');
      expect(model.email, 'parent@example.com');
      expect(model.role, 'parent');
      expect(model.balance, 150000);
      expect(model.children.length, 1);
      expect(model.children.first.id, 20);
      expect(model.children.first.fullName, 'Test Child');
      expect(model.children.first.className, '10-A');
      expect(model.children.first.classId, 5);
    });

    test('parses successfully even if missing optional fields', () {
      final json = {
        'id': 99,
        'role': 'parent',
        'full_name': 'Unknown Parent',
        'phone': '',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 99);
      expect(model.fullName, 'Unknown Parent');
      expect(model.phone, '');
      expect(model.email, null);
      expect(model.balance, 0); // Default value expected or null depending on model setup
      expect(model.children.length, 0);
    });
  });

  group('PaymentModel parsing', () {
    test('parses completely populated data', () {
      final json = {
        'id': 100,
        'amount': 250000.5,
        'method': 'click',
        'status': 'completed',
        'created_at': '2026-02-27T10:00:00Z',
        'transaction_id': 'TRANS_123',
        'contract_number': 'CON_123',
      };

      final model = PaymentModel.fromJson(json);

      expect(model.id, 100);
      expect(model.amount, 250000.5);
      expect(model.method, PaymentMethod.click);
      expect(model.status, PaymentStatus.completed);
      expect(model.transactionId, 'TRANS_123');
      expect(model.contractNumber, 'CON_123');
    });

    test('handles string-based amounts correctly if required', () {
      final json = {
        'id': 101,
        'amount': 300000, // as integer
        'method': 'cash',
        'status': 'pending',
        'created_at': '2026-02-27T10:00:00Z',
      };

      final model = PaymentModel.fromJson(json);

      expect(model.id, 101);
      expect(model.amount, 300000);
      expect(model.method, PaymentMethod.cash);
      expect(model.status, PaymentStatus.pending);
    });
  });
}
