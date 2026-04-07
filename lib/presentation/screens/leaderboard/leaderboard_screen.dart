import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
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

    final colorScheme = Theme.of(context).colorScheme;

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
              color: colorScheme.surfaceContainerHighest,
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
              color: const Color(0xFFCD7F32),
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
        CircleAvatar(
          radius: isFirst ? 34 : 26,
          backgroundColor: theme.cardColor,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name.split(' ').first,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: colorScheme.onSurface,
          ),
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = data['avatar_url']?.toString();
    final xp = data['xp']?.toString() ?? '0';
    final level = data['level']?.toString() ?? '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? colorScheme.primary.withValues(alpha: 0.08)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
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
              data['name']?.toString() ?? l10n.userFallbackName,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                l10n.levelBadge(int.tryParse(level) ?? 1),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.leaderboardCoins(coins),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  l10n.unlockableBadgesCount(availableBadges.length),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.myBadgesTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.category,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
