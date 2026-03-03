import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ref.read(userProvider.notifier).changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
          confirmPassword: _confirmController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parol muvaffaqiyatli o\'zgartirildi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parolni o\'zgartirish')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentController,
                decoration: const InputDecoration(labelText: 'Joriy parol'),
                obscureText: true,
                validator: (v) => v?.isEmpty == true ? 'Kiritish shart' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                decoration: const InputDecoration(labelText: 'Yangi parol'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length < 8 ? 'Eng kamida 8 ta belgi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Parolni tasdiqlang'),
                obscureText: true,
                validator: (v) =>
                    v != _newController.text ? 'Parollar mos kelmadi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
