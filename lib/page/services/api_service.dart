import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://26.100.59.12:8000';

  static Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': id,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('รหัสผ่านไม่ถูกต้อง');
      }
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e');
    }
  }
}
