import 'package:http/http.dart' as http;

// Ganti dengan URL backend Node.js Anda
const String baseURL = "http://192.168.1.123:5002"; 

class ApiService {
  // Metode untuk mendapatkan header HTTP dengan token JWT
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}