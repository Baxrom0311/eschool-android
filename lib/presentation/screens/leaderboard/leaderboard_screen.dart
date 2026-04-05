import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/badge_model.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }

  void _loadLeaderboard() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      ref.read(leaderboardProvider.notifier).loadData(child.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadLeaderboard();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Liderlar Jadvali',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Sinf'),
            Tab(text: 'Maktab'),
            Tab(text: 'Nishonlar'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _RankingTab(
                  ranking: state.classRanking,
                  myRank: state.classRank,
                  emptyText: 'Sinf reytingi hozircha yo\'q',
                ),
                _RankingTab(
                  ranking: state.globalRanking,
                  myRank: state.globalRank,
                  emptyText: 'Maktab reytingi hozircha yo\'q',
                ),
                _BadgesTab(
                  coins: state.coins,
                  myBadges: state.myBadges,
                  availableBadges: state.availableBadges,
                ),
              ],
            ),
    );
  }
}

class _RankingTab extends StatelessWidget {
  const _RankingTab({
    required this.ranking,
    required this.myRank,
    required this.emptyText,
  });

  final List<Map<String, dynamic>> ranking;
  final int? myRank;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final top3 = ranking.take(3).toList();
    final rest = ranking.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Podium(top3: top3),
        const SizedBox(height: 24),
        ...rest.map(
          (item) => _RankTile(data: item, isMe: item['rank'] == myRank),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});

  final List<Map<String, dynamic>> top3;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 280,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1)
            _PodiumItem(
              data: top3[1],
              rank: 2,
              height: 118,
              color: Colors.grey.shade300,
            ),
          _PodiumItem(
            data: top3[0],
            rank: 1,
            height: 152,
            color: const Color(0xFFFFD700),
            isFirst: true,
          ),
          if (top3.length > 2)
            _PodiumItem(
              data: top3[2],
              rank: 3,
              height: 102,
              color: Colors.brown.shade300,
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.data,
    required this.rank,
    required this.height,
    required this.color,
    this.isFirst = false,
  });

  final Map<String, dynamic> data;
  final int rank;
  final double height;
  final Color color;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = data['avatar_url']?.toString();
    final name = data['name']?.toString() ?? 'Noma\'lum';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: isFirst ? 34 : 26,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name.split(' ').first,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          width: 78,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.32),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.data, required this.isMe});

  final Map<String, dynamic> data;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = data['avatar_url']?.toString();
    final xp = data['xp']?.toString() ?? '0';
    final level = data['level']?.toString() ?? '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppColors.primaryBlue) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${data['rank'] ?? '-'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data['name']?.toString() ?? 'Noma\'lum',
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Text(
                'Lvl $level',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({
    required this.coins,
    required this.myBadges,
    required this.availableBadges,
  });

  final int coins;
  final List<BadgeModel> myBadges;
  final List<BadgeModel> availableBadges;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Column(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 8),
                Text(
                  '$coins Tangalar',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Ochiladigan nishonlar: ${availableBadges.length}'),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mening nishonlarim',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (myBadges.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Hali nishonlar yo\'q')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final badge = myBadges[index];
                return _BadgeCard(badge: badge);
              }, childCount: myBadges.length),
            ),
          ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.icon, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.category,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
