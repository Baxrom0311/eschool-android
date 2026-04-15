import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/quiz_api.dart';
import '../../data/models/quiz_model.dart';
import 'auth_provider.dart';

final quizApiProvider = Provider<QuizApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return QuizApi(dioClient);
});

// ─── Quiz List ───

class QuizListState {
  final bool isLoading;
  final String? error;
  final List<QuizModel> quizzes;

  const QuizListState({
    this.isLoading = false,
    this.error,
    this.quizzes = const [],
  });

  QuizListState copyWith({
    bool? isLoading,
    String? error,
    List<QuizModel>? quizzes,
  }) {
    return QuizListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      quizzes: quizzes ?? this.quizzes,
    );
  }
}

class QuizListNotifier extends StateNotifier<QuizListState> {
  final QuizApi _api;

  QuizListNotifier(this._api) : super(const QuizListState());

  Future<void> loadQuizzes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final quizzes = await _api.getStudentQuizzes();
      state = QuizListState(quizzes: quizzes);
    } catch (e) {
      state = QuizListState(error: e.toString());
    }
  }
}

final quizListProvider =
    StateNotifierProvider.autoDispose<QuizListNotifier, QuizListState>(
  (ref) {
    final api = ref.watch(quizApiProvider);
    return QuizListNotifier(api);
  },
);

// ─── Quiz Session (Taking a quiz) ───

class QuizSessionState {
  final bool isLoading;
  final String? error;
  final QuizAttemptStart? attempt;
  final Map<int, int> answers; // questionIndex -> selectedOptionIndex
  final bool isSubmitting;
  final QuizSubmitResult? result;

  const QuizSessionState({
    this.isLoading = false,
    this.error,
    this.attempt,
    this.answers = const {},
    this.isSubmitting = false,
    this.result,
  });

  QuizSessionState copyWith({
    bool? isLoading,
    String? error,
    QuizAttemptStart? attempt,
    Map<int, int>? answers,
    bool? isSubmitting,
    QuizSubmitResult? result,
  }) {
    return QuizSessionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      attempt: attempt ?? this.attempt,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  final QuizApi _api;

  QuizSessionNotifier(this._api) : super(const QuizSessionState());

  Future<void> startQuiz(int quizId) async {
    state = const QuizSessionState(isLoading: true);
    try {
      final attempt = await _api.startQuiz(quizId);
      state = QuizSessionState(attempt: attempt);
    } catch (e) {
      state = QuizSessionState(error: e.toString());
    }
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    final updated = Map<int, int>.from(state.answers);
    updated[questionIndex] = optionIndex;
    state = state.copyWith(answers: updated);
  }

  Future<void> submitQuiz(int quizId) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final answersMap = <String, dynamic>{};
      state.answers.forEach((qIdx, aIdx) {
        answersMap[qIdx.toString()] = aIdx;
      });
      final result = await _api.submitQuiz(quizId, answersMap);
      state = state.copyWith(isSubmitting: false, result: result);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final quizSessionProvider =
    StateNotifierProvider.autoDispose<QuizSessionNotifier, QuizSessionState>(
  (ref) {
    final api = ref.watch(quizApiProvider);
    return QuizSessionNotifier(api);
  },
);
