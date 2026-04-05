class LibraryBookModel {
  final int id;
  final String title;
  final String author;
  final String category;
  final String? coverUrl;
  final String? downloadUrl;

  LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    this.coverUrl,
    this.downloadUrl,
  });

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    return LibraryBookModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      coverUrl: json['cover_url']?.toString(),
      downloadUrl: json['download_url']?.toString(),
    );
  }
}
