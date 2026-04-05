import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/leaderboard_api.dart';
import '../../data/models/badge_model.dart';
import 'auth_provider.dart';

final leaderboardApiProvider = Provider<LeaderboardApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LeaderboardApi(dioClient);
});

class LeaderboardState {
  final int coins;
  final List<BadgeModel> availableBadges;
  final List<BadgeModel> myBadges;
  final List<Map<String, dynamic>> globalRanking;
  final List<Map<String, dynamic>> classRanking;
  final int? globalRank;
  final int? classRank;
  final bool isLoading;

  const LeaderboardState({
    this.coins = 0,
    this.availableBadges = const [],
    this.myBadges = const [],
    this.globalRanking = const [],
    this.classRanking = const [],
    this.globalRank,
    this.classRank,
    this.isLoading = false,
  });

  LeaderboardState copyWith({
    int? coins,
    List<BadgeModel>? availableBadges,
    List<BadgeModel>? myBadges,
    List<Map<String, dynamic>>? globalRanking,
    List<Map<String, dynamic>>? classRanking,
    int? globalRank,
    int? classRank,
    bool? isLoading,
  }) {
    return LeaderboardState(
      coins: coins ?? this.coins,
      availableBadges: availableBadges ?? this.availableBadges,
      myBadges: myBadges ?? this.myBadges,
      globalRanking: globalRanking ?? this.globalRanking,
      classRanking: classRanking ?? this.classRanking,
      globalRank: globalRank ?? this.globalRank,
      classRank: classRank ?? this.classRank,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardApi _api;

  LeaderboardNotifier(this._api) : super(const LeaderboardState());

  Future<void> loadData(int childId) async {
    state = state.copyWith(isLoading: true);
    try {
      final coins = await _api.getCoins(childId);
      final myBadges = await _api.getMyBadges(childId);
      final availableBadges = await _api.getBadges(childId: childId);
      
      final globalResp = await _api.getGlobalLeaderboard();
      final classResp = await _api.getClassLeaderboard();

      state = state.copyWith(
        coins: coins,
        myBadges: myBadges,
        availableBadges: availableBadges,
        globalRanking: List<Map<String, dynamic>>.from(globalResp['leaderboard'] ?? []),
        classRanking: List<Map<String, dynamic>>.from(classResp['leaderboard'] ?? []),
        globalRank: globalResp['my_rank'],
        classRank: classResp['my_rank'],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(ref.watch(leaderboardApiProvider));
});
