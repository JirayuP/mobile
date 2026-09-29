class Pokemon {
  final String id;
  final String name;
  final String height;
  final String weight;
  final String sprites;
  final String types;
  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.sprites,
    required this.types,
  });

  // แปลง JSON (Map) → Quote — เหมือน fromMap ของ SQLite!
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] ?? '',
      name: json['name'] ?? 'ไม่ทราบ',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      sprites: json['sprites'] ?? '',
      types: json['types'] ?? '',
    );
  }
}
