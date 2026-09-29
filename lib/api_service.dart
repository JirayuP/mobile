import 'dart:convert'; // สำหรับ jsonDecode
import 'package:http/http.dart' as http;
import 'package:mydiary/quote.dart';
import 'package:mydiary/pokemon.dart';

class ApiService {
  // ดึงคำคมสุ่ม
  static Future<Quote> fetchQuote() async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/25');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('เซิร์ฟเวอร์ตอบผิดพลาด (${response.statusCode})');
      }
    } catch (e) {
      // จับ error ทุกแบบ (เน็ตหลุด/timeout/เซิร์ฟเวอร์พัง)
      throw Exception('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }

  // ดึงคำคมสุ่ม
  static Future<Pokemon> fetchPokemon() async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/25');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('เซิร์ฟเวอร์ตอบผิดพลาด (${response.statusCode})');
      }
    } catch (e) {
      // จับ error ทุกแบบ (เน็ตหลุด/timeout/เซิร์ฟเวอร์พัง)
      throw Exception('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }
}
