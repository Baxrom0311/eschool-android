import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../data/models/library_model.dart';
import '../../providers/library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.digitalLibraryTitle),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: l10n.libraryBooksTab),
            Tab(text: l10n.libraryMyBooksTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBooksTab(), _buildMyLoansTab()],
      ),
    );
  }

  Widget _buildBooksTab() {
    final l10n = context.l10n;
    final booksAsync = ref.watch(libraryBooksProvider({'query': _query}));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.librarySearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _query = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (val) {
              setState(() => _query = val);
            },
          ),
        ),
        Expanded(
          child: booksAsync.when(
            data: (books) => books.isEmpty
                ? Center(child: Text(l10n.libraryNoBooksFound))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final LibraryBookModel book = books[index];
                      return _buildBookCard(book);
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text(ApiErrorHandler.readableMessage(err))),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(LibraryBookModel book) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(book.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.coverUrl == null || book.coverUrl!.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  book.author.isEmpty ? l10n.libraryUnknownAuthor : book.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: book.availableCopies > 0
                        ? () => _borrowBook(book.id)
                        : null,
                    child: Text(
                      book.availableCopies > 0
                          ? l10n.libraryBorrowAction
                          : l10n.libraryUnavailableAction,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLoansTab() {
    final l10n = context.l10n;
    final loansAsync = ref.watch(myLoansProvider);

    return loansAsync.when(
      data: (loans) => loans.isEmpty
          ? Center(child: Text(l10n.libraryNoLoans))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                final book = loan['book'] is Map
                    ? Map<String, dynamic>.from(loan['book'] as Map)
                    : <String, dynamic>{};
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    title: Text(
                      book['title']?.toString() ?? l10n.libraryUnknownBook,
                    ),
                    subtitle: Text(
                      l10n.libraryLoanDates(
                        loan['borrowed_at']?.toString() ?? '-',
                        loan['due_at']?.toString() ?? '-',
                      ),
                    ),
                    trailing: loan['status'] == 'borrowed'
                        ? TextButton(
                            onPressed: () => _returnBook(loan['id']),
                            child: Text(l10n.libraryReturnAction),
                          )
                        : Text(
                            l10n.libraryReturnedStatus,
                            style: const TextStyle(color: Colors.green),
                          ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text(ApiErrorHandler.readableMessage(err))),
    );
  }

  Future<void> _borrowBook(int id) async {
    final l10n = context.l10n;
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .borrow(id);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.libraryBorrowedSuccess)));
      _tabController.animateTo(1);
    }
  }

  Future<void> _returnBook(int id) async {
    final l10n = context.l10n;
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .returnBook(id);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.libraryReturnedSuccess)));
    }
  }
}
