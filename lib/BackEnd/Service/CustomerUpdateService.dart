import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/customer_add_model.dart';
 // Assuming your Customer model is here
class CustomerUpdateService {
  final String _baseUrl = "http://localhost:58691/api/Clinic";

  Future<bool> updateCustomer(CustomerHeader customer) async {
    final url = Uri.parse('$_baseUrl/UpdateCustomer');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to update customer. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }
}