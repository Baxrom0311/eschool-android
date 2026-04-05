import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/library_api.dart';
import '../../data/models/library_model.dart';
import 'auth_provider.dart';

final libraryApiProvider = Provider<LibraryApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LibraryApi(dioClient);
});

class LibraryState {
  final List<LibraryBookModel> books;
  final List<Map<String, dynamic>> categories;
  final bool isLoading;
  final String? error;

  const LibraryState({
    this.books = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  LibraryState copyWith({
    List<LibraryBookModel>? books,
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LibraryState(
      books: books ?? this.books,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final LibraryApi _api;

  LibraryNotifier(this._api) : super(const LibraryState());

  Future<void> loadLibrary({int? categoryId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final books = await _api.getBooks(categoryId: categoryId);
      final categories = state.categories.isEmpty 
          ? await _api.getCategories() 
          : state.categories;
          
      state = state.copyWith(
        books: books,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier(ref.watch(libraryApiProvider));
});
