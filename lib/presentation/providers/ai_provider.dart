import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ai_insight_model.dart';
import '../../data/repositories/ai_insight_repository.dart';
import 'auth_provider.dart';

class AiInsightState {
  final bool isLoading;
  final String? error;
  final AiInsightModel? insight;

  const AiInsightState({this.isLoading = false, this.error, this.insight});

  AiInsightState copyWith({bool? isLoading, String? error, AiInsightModel? insight}) {
    return AiInsightState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      insight: insight ?? this.insight,
    );
  }
}

class AiInsightNotifier extends StateNotifier<AiInsightState> {
  final AiInsightRepository _repository;

  AiInsightNotifier(this._repository) : super(const AiInsightState());

  Future<void> loadInsights(int studentId) async {
    state = state.copyWith(isLoading: true);
    try {
      final insight = await _repository.getStudentInsights(studentId);
      state = AiInsightState(insight: insight);
    } catch (e) {
      state = AiInsightState(error: e.toString());
    }
  }
}

final aiInsightProvider = StateNotifierProvider<AiInsightNotifier, AiInsightState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AiInsightNotifier(AiInsightRepository(dioClient));
});
