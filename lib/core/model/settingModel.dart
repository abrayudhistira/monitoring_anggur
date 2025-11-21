class Setting {
  final int id;
  final String namaSetting;
  final String status;
  final DateTime? updatedAt; // Gunakan DateTime karena di-parse dari string ISO 8601

  Setting({
    required this.namaSetting,
    required this.status,
    this.id = 0, // Beri nilai default 0 jika id tidak ada (walaupun seharusnya selalu ada)
    this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    // Parsing string ISO 8601 ke objek DateTime
    DateTime? parsedDate;
    if (json['updatedAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['updatedAt'] as String);
      } catch (e) {
        print('Error parsing updatedAt: $e');
      }
    }
    
    return Setting(
      id: json['id'] as int? ?? 0,
      namaSetting: json['namaSetting'] as String,
      status: json['status'] as String,
      updatedAt: parsedDate,
    );
  }
}