import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/absence_provider.dart';
import '../../providers/user_provider.dart';

class AbsenceExcuseScreen extends ConsumerStatefulWidget {
  const AbsenceExcuseScreen({super.key});

  @override
  ConsumerState<AbsenceExcuseScreen> createState() => _AbsenceExcuseScreenState();
}

class _AbsenceExcuseScreenState extends ConsumerState<AbsenceExcuseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = ref.read(selectedChildProvider);
      if (child != null) {
        ref.read(absenceProvider.notifier).loadExcuses(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(absenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Murojaat (Davomat)'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.excuses.length,
              itemBuilder: (context, index) {
                final excuse = state.excuses[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_late, color: Colors.redAccent),
                    title: Text(excuse.reason),
                    subtitle: Text('${excuse.dateFrom} - ${excuse.dateTo}'),
                    trailing: Chip(
                      label: Text(excuse.status),
                      backgroundColor: excuse.status == 'approved' ? Colors.green.shade100 : Colors.yellow.shade100,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          // Open Modal to Submit Excuse
        },
        icon: const Icon(Icons.add),
        label: const Text('Murojaat qoldirish'),
      ),
    );
  }
}
