import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import 'package:parent_school_app/presentation/widgets/common/glass_app_bar.dart';
import 'package:parent_school_app/presentation/widgets/common/page_background.dart';
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

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadLeaderboard();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        toolbarHeight: kToolbarHeight,
        title: Text(
          l10n.leaderboardTitle.toUpperCase(),
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 16,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: l10n.leaderboardClassTab.toUpperCase()),
            Tab(text: l10n.leaderboardSchoolTab.toUpperCase()),
            Tab(text: l10n.leaderboardBadgesTab.toUpperCase()),
          ],
        ),
      ),
      body: PageBackground(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight + 52),
                child: TabBarView(
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
              ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        _Podium(top3: top3),
        const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1)
            _PodiumItem(
              data: top3[1],
              rank: 2,
              height: 100,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3), // Silver/Slate
            ),
          _PodiumItem(
            data: top3[0],
            rank: 1,
            height: 140,
            color: AppColors.amber, // Gold/Amber
            isFirst: true,
          ),
          if (top3.length > 2)
            _PodiumItem(
              data: top3[2],
              rank: 3,
              height: 80,
              color: AppColors.warning, // Bronze/Brown
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
                color: color.withValues(alpha: 0.1),
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
                  fontSize: 26,
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isMe
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: isMe ? 1.5 : 1,
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
                color: isMe ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.slate900,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.slate950,
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
                  child: const Icon(Icons.monetization_on, size: 48, color: AppColors.coinAmber),
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1),
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
