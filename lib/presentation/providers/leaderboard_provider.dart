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
  final bool isLoading;

  const LeaderboardState({
    this.coins = 0,
    this.availableBadges = const [],
    this.myBadges = const [],
    this.isLoading = false,
  });

  LeaderboardState copyWith({
    int? coins,
    List<BadgeModel>? availableBadges,
    List<BadgeModel>? myBadges,
    bool? isLoading,
  }) {
    return LeaderboardState(
      coins: coins ?? this.coins,
      availableBadges: availableBadges ?? this.availableBadges,
      myBadges: myBadges ?? this.myBadges,
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
      state = state.copyWith(
        coins: coins,
        myBadges: myBadges,
        availableBadges: availableBadges,
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
