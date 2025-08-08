// lib/services/customer_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';


class CustomerService {
  final String _baseUrl = "http://localhost:58691/api/Clinic";

  Future<List<CustomerWithPets>> getAllCustomers() async {
    final response = await http.get(Uri.parse('$_baseUrl/GetAllCustomers'));

    if (response.statusCode == 200) {
      // The API returns a list of objects directly.
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      
      // Map each object in the list to our CustomerWithPets model.
      return jsonList
          .map((json) => CustomerWithPets.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load customers. Status code: ${response.statusCode}');
    }
  }
}
