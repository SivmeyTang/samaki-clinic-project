import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/PostProduct_Model.dart';


class PostProductService {
  static const String _baseUrl = 'http://localhost:58691/api/Clinic';
  static const Duration _timeout = Duration(seconds: 30);

  Future<bool> postProduct(PostProduct product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/PostProduct'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true || responseData == true;
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to post product: $e');
    }
  }
}