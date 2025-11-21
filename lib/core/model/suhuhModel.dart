class Suhu {
  final int id;
  final double humidity;
  final DateTime timestamp;

  Suhu({
    required this.id,
    required this.humidity,
    required this.timestamp,
  });

  factory Suhu.fromJson(Map<String, dynamic> json) {
    return Suhu(
      id: json['id'] as int,
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}