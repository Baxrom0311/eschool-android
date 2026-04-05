class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final String icon;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      icon: json['icon_url']?.toString() ?? json['icon']?.toString() ?? '',
    );
  }
}
