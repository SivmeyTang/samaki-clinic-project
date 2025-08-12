// lib/services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:js_interop';
import 'package:http/http.dart' as http;
import 'package:samaki_clinic/BackEnd/Model/PostProduct_Model.dart';
import 'package:samaki_clinic/BackEnd/Model/Product_Model.dart';

/// A custom exception class for more detailed API error feedback.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'API Error ($statusCode): $message';
    }
    return 'API Error: $message';
  }
}

class ProductService {
  // Use 10.0.2.2 to connect to your PC's localhost from the Android emulator.
  static const String _baseUrl = 'http://localhost:58691/api/Clinic';
  static const Duration _timeout = Duration(seconds: 30);

  /// Centralized helper for handling all HTTP requests.
  Future<http.Response> _handleRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw ApiException(response.body, response.statusCode);
      }
    } on SocketException {
      throw ApiException('No Internet connection or server not reachable.');
    } on TimeoutException {
      throw ApiException('The connection has timed out. Please try again.');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Fetches all products.
  Future<List<ProductModel>> getAllProducts() async {
    final response = await _handleRequest(
        () => http.get(Uri.parse('$_baseUrl/GetAllProducts')));
    final List<dynamic> productJson = jsonDecode(response.body);
    return productJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  /// Creates a new product.
  Future<bool> postProduct(PostProduct product) async {
    await _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/PostProduct'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        ));
    return true;
  }

  /// Updates an existing product.
  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    await _handleRequest(() => http.put(
          Uri.parse('$_baseUrl/PutProduct/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(productData),
        ));
    return true;
  }

  /// Deletes a product by its ID.
  Future<bool> deleteProduct(int id) async {
    await _handleRequest(
        () => http.delete(Uri.parse('$_baseUrl/DeleteProduct/$id')));
    return true;
  }
}
