import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/invoice_model.dart';


// A dedicated class for handling the response from saving an invoice
class SaveInvoiceResponse {
  final bool success;
  final String message;

  SaveInvoiceResponse({required this.success, required this.message});

  factory SaveInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return SaveInvoiceResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}


class InvoiceService {
  final String baseUrl;

  InvoiceService({required this.baseUrl});

  // Method to fetch all invoices from the API
  Future<InvoiceResponse> getAllInvoices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Clinic/GetAllInvoices'),
    );

    if (response.statusCode == 200) {
      return InvoiceResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load invoices');
    }
  }

  // Method to post a new invoice to the API
  Future<SaveInvoiceResponse> postInvoice(Invoice invoice) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Clinic/SaveInvoice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(invoice.toJson()),
    );

    if (response.statusCode == 200) {
      return SaveInvoiceResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to save invoice. Status code: ${response.statusCode}');
    }
  }
}