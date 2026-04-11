import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/constants/app_colors.dart';
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
    final l10n = context.l10n;
    final state = ref.watch(leaderboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadLeaderboard();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.leaderboardTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: l10n.leaderboardClassTab),
            Tab(text: l10n.leaderboardSchoolTab),
            Tab(text: l10n.leaderboardBadgesTab),
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
                  emptyText: l10n.leaderboardClassEmpty,
                ),
                _RankingTab(
                  ranking: state.globalRanking,
                  myRank: state.globalRank,
                  emptyText: l10n.leaderboardSchoolEmpty,
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
      return Center(
        child: Text(
          emptyText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final top3 = ranking.take(3).toList();
    final rest = ranking.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _Podium(top3: top3),
        const SizedBox(height: 32),
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
      height: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1)
            _PodiumItem(
              data: top3[1],
              rank: 2,
              height: 100,
              color: const Color(0xFF94A3B8), // Silver/Slate
            ),
          _PodiumItem(
            data: top3[0],
            rank: 1,
            height: 140,
            color: const Color(0xFFF59E0B), // Gold/Amber
            isFirst: true,
          ),
          if (top3.length > 2)
            _PodiumItem(
              data: top3[2],
              rank: 3,
              height: 80,
              color: const Color(0xFFB45309), // Bronze/Brown
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = data['avatar_url']?.toString();
    final name = data['name']?.toString() ?? context.l10n.userFallbackName;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: isFirst ? 42 : 32,
            backgroundColor: AppColors.slate100,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Icon(Icons.person, color: color, size: isFirst ? 36 : 28)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name.split(' ').first,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: 84,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'RANK',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = data['avatar_url']?.toString();
    final xp = data['xp']?.toString() ?? '0';
    final level = data['level']?.toString() ?? '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMe
              ? AppColors.primaryBlue.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.5),
          width: isMe ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${data['rank'] ?? '-'}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isMe ? AppColors.primaryBlue : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe ? AppColors.primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.slate100,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data['name']?.toString() ?? l10n.userFallbackName,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.levelBadge(int.tryParse(level) ?? 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.slate900,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBlue,
                  AppColors.primaryBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.monetization_on, size: 48, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.leaderboardCoins(coins),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.unlockableBadgesCount(availableBadges.length),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              l10n.myBadgesTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        if (myBadges.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l10n.noBadgesYet,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: Text(badge.icon, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),
          Text(
            badge.name,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge.category.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
