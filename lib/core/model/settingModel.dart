class Setting {
  final int id;
  final String namaSetting;
  final String status;
  final DateTime? updatedAt;

  Setting({
    required this.namaSetting,
    required this.status,
    this.id = 0,
    this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;

    // Pastikan key json-nya benar (kadang 'updatedAt', kadang 'updated_at' tergantung backend)
    // Di sini saya ikuti kode Anda pakai 'updatedAt'
    if (json['updatedAt'] != null) {
      try {
        // --- PERBAIKAN DI SINI ---
        String dateStr = json['updatedAt'].toString();

        // 1. Cek apakah ada huruf 'Z' di belakang. Kalau tidak ada, tambahkan.
        // Ini memaksa Dart membaca waktu tersebut sebagai UTC (Jam 09:00 UTC).
        if (!dateStr.endsWith('Z')) {
          dateStr += 'Z';
        }

        // 2. Parse sebagai UTC, lalu konversi ke Waktu Lokal HP (.toLocal())
        // Hasilnya: 09:00 UTC + 7 Jam = 16:00 WIB.
        parsedDate = DateTime.parse(dateStr).toLocal();
        // -------------------------
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
