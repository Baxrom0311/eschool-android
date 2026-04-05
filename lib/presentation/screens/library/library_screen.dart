import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maktab Kutubxonasi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Kitoblar'),
            Tab(text: 'Mening kitoblarim'),
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
    final booksAsync = ref.watch(libraryBooksProvider({'query': _query}));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kitob qidirish...',
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
                ? const Center(child: Text('Kitoblar topilmadi'))
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
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
                  ? const Center(
                      child: Icon(Icons.book, size: 48, color: Colors.grey),
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
                  book.author.isEmpty ? 'Muallif noma\'lum' : book.author,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: book.availableCopies > 0
                        ? () => _borrowBook(book.id)
                        : null,
                    child: Text(
                      book.availableCopies > 0 ? 'Olish' : 'Mavjud emas',
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
    final loansAsync = ref.watch(myLoansProvider);

    return loansAsync.when(
      data: (loans) => loans.isEmpty
          ? const Center(child: Text('Sizda olingan kitoblar yo\'q'))
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
                  child: ListTile(
                    title: Text(book['title']?.toString() ?? 'Noma\'lum kitob'),
                    subtitle: Text(
                      'Olindi: ${loan['borrowed_at']} | Qaytish: ${loan['due_at']}',
                    ),
                    trailing: loan['status'] == 'borrowed'
                        ? TextButton(
                            onPressed: () => _returnBook(loan['id']),
                            child: const Text('Qaytarish'),
                          )
                        : const Text(
                            'Qaytarilgan',
                            style: TextStyle(color: Colors.green),
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
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .borrow(id);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kitob band qilindi!')));
      _tabController.animateTo(1);
    }
  }

  Future<void> _returnBook(int id) async {
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .returnBook(id);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kitob qaytarildi!')));
    }
  }
}
