// models/region.dart
class Region {
  final String id;
  final String name;

  Region({required this.id, required this.name});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id']?.toString() ?? 'tidak nampil',
      name: json['name'] ?? 'tidak nampil',
    );
  }
}
