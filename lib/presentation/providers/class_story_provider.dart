import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/class_story_api.dart';
import '../../data/models/class_story_model.dart';
import 'auth_provider.dart';

// ─── Dependency ───

final classStoryApiProvider = Provider<ClassStoryApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ClassStoryApi(dioClient);
});

// ─── State ───

class ClassStoryState {
  final bool isLoading;
  final String? error;
  final List<ClassStoryModel> stories;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const ClassStoryState({
    this.isLoading = false,
    this.error,
    this.stories = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  ClassStoryState copyWith({
    bool? isLoading,
    String? error,
    List<ClassStoryModel>? stories,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return ClassStoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stories: stories ?? this.stories,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ─── Notifier ───

class ClassStoryNotifier extends StateNotifier<ClassStoryState> {
  final ClassStoryApi _api;

  ClassStoryNotifier(this._api) : super(const ClassStoryState());

  Future<void> loadStories({int? groupId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stories = await _api.getStories(groupId: groupId, page: 1);
      final meta = await _api.getMeta(groupId: groupId, page: 1);
      state = state.copyWith(
        isLoading: false,
        stories: stories,
        currentPage: meta['current_page'] ?? 1,
        lastPage: meta['last_page'] ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore({int? groupId}) async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final stories = await _api.getStories(groupId: groupId, page: nextPage);
      final meta = await _api.getMeta(groupId: groupId, page: nextPage);
      state = state.copyWith(
        isLoadingMore: false,
        stories: [...state.stories, ...stories],
        currentPage: meta['current_page'] ?? nextPage,
        lastPage: meta['last_page'] ?? state.lastPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> toggleLike(int storyId) async {
    final index = state.stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;

    final story = state.stories[index];
    final optimistic = story.copyWith(
      isLiked: !story.isLiked,
      likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
    );
    final updated = List<ClassStoryModel>.from(state.stories);
    updated[index] = optimistic;
    state = state.copyWith(stories: updated);

    try {
      await _api.toggleLike(storyId);
    } catch (_) {
      // Revert on failure
      final reverted = List<ClassStoryModel>.from(state.stories);
      reverted[index] = story;
      state = state.copyWith(stories: reverted);
    }
  }

  Future<void> addComment(int storyId, String body) async {
    try {
      final comment = await _api.addComment(storyId, body);
      final index = state.stories.indexWhere((s) => s.id == storyId);
      if (index == -1) return;
      final story = state.stories[index];
      final updated = List<ClassStoryModel>.from(state.stories);
      updated[index] = story.copyWith(
        commentsCount: story.commentsCount + 1,
        comments: [...story.comments, comment],
      );
      state = state.copyWith(stories: updated);
    } catch (_) {}
  }
}

// ─── Provider ───

final classStoryProvider =
    StateNotifierProvider.autoDispose<ClassStoryNotifier, ClassStoryState>(
  (ref) {
    final api = ref.watch(classStoryApiProvider);
    return ClassStoryNotifier(api);
  },
);
