import 'package:http/http.dart' as http;

// Ganti dengan URL backend Node.js Anda
// const String baseURL = "https://itshowcase.umy.ac.id/2025/smartgrape"; 
const String baseURL = "https://yht.co.id"; 

class ApiService {
  // Metode untuk mendapatkan header HTTP dengan token JWT
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}