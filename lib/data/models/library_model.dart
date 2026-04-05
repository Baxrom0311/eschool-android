class LibraryBookModel {
  final int id;
  final String title;
  final String author;
  final String category;
  final int availableCopies;
  final String? description;
  final String? coverUrl;
  final String? downloadUrl;

  LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.availableCopies,
    this.description,
    this.coverUrl,
    this.downloadUrl,
  });

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    final availableCopiesValue = json['available_copies'];

    return LibraryBookModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      availableCopies: availableCopiesValue is int
          ? availableCopiesValue
          : int.tryParse(availableCopiesValue?.toString() ?? '') ?? 0,
      description: json['description']?.toString(),
      coverUrl:
          json['cover_image']?.toString() ?? json['cover_url']?.toString(),
      downloadUrl: json['download_url']?.toString(),
    );
  }
}
