import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/customer_add_model.dart';

class CustomerAddService {
  final String baseUrl = 'http://localhost:58691/api/Clinic';

  Future<bool> saveCustomer(CustomerRequestModel data) async {
    final url = Uri.parse('$baseUrl/SaveCustomer');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed: ${response.body}');
      return false;
    }
  }
}
