class Quote {
  final String text;
  final String author;
  Quote({required this.text, required this.author});

  // แปลง JSON (Map) → Quote — เหมือน fromMap ของ SQLite!
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] ?? '',
      author: json['author'] ?? 'ไม่ทราบ',
    );
  }
}
