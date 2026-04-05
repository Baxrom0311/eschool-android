import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/library_api.dart';
import '../../data/models/library_model.dart';
import 'auth_provider.dart';

final libraryApiProvider = Provider<LibraryApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LibraryApi(dioClient);
});

final libraryBooksProvider =
    FutureProvider.family<List<LibraryBookModel>, Map<String, String>>((
      ref,
      params,
    ) {
      return ref
          .watch(libraryApiProvider)
          .getBooks(category: params['category'], query: params['query']);
    });

final myLoansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(libraryApiProvider).getMyLoans();
});

class LibraryController extends StateNotifier<AsyncValue<void>> {
  LibraryController(this._api, this._ref) : super(const AsyncValue.data(null));

  final LibraryApi _api;
  final Ref _ref;

  Future<bool> borrow(int bookId) async {
    state = const AsyncValue.loading();
    try {
      await _api.borrowBook(bookId);
      state = const AsyncValue.data(null);
      _ref.invalidate(myLoansProvider);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> returnBook(int loanId) async {
    state = const AsyncValue.loading();
    try {
      await _api.returnBook(loanId);
      state = const AsyncValue.data(null);
      _ref.invalidate(myLoansProvider);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final libraryControllerProvider =
    StateNotifierProvider<LibraryController, AsyncValue<void>>((ref) {
      return LibraryController(ref.watch(libraryApiProvider), ref);
    });
