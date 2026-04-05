import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = ref.read(selectedChildProvider);
      if (child != null) {
        ref.read(leaderboardProvider.notifier).loadData(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yutuqlar va Nishonlar'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    child: Column(
                      children: [
                        const Icon(Icons.monetization_on, size: 64, color: Colors.amber),
                        const SizedBox(height: 8),
                        Text(
                          '${state.coins} Tangalar',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('Faollik va a\'lo baholar uchun berilgan!'),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Mening nishonlarim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final badge = state.myBadges[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(badge.icon, style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(badge.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            Text(badge.category, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                    childCount: state.myBadges.length,
                  ),
                ),
              ],
            ),
    );
  }
}
