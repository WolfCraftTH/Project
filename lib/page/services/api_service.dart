import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String _baseUrl = 'http://26.100.59.12:8000';
  static const String _port = '8000';

  // เพิ่มฟังก์ชันสำหรับดึงที่อยู่เซิร์ฟเวอร์ปัจจุบัน
  static String getServerAddress() {
    // ตัดส่วน http:// และ port ออก เหลือแค่ IP address
    return _baseUrl.replaceAll('http://', '').replaceAll(':$_port', '');
  }

  // เพิ่มฟังก์ชันสำหรับตั้งค่าที่อยู่เซิร์ฟเวอร์ใหม่
  static void setServerAddress(String newAddress) {
    _baseUrl = 'http://$newAddress:$_port';
  }

  static Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
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
