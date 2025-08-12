import 'package:flutter/material.dart';
import 'package:samaki_clinic/BackEnd/Model/customer_add_model.dart';
import 'package:samaki_clinic/BackEnd/Service/CustomerUpdateService.dart';

class CustomerUpdateProvider extends ChangeNotifier {
  final CustomerUpdateService _service = CustomerUpdateService();
  
  // A single private variable for loading state.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // A single private variable for errors.
  String? _error;
  String? get error => _error;

  /// Private helper to reduce boilerplate for API calls.
  /// It handles loading state, error catching, and notifying listeners.
  Future<T?> _callApi<T>(Future<T> Function() apiCall) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await apiCall();
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates a customer and returns true on success, false on failure.
  Future<bool> updateCustomer(CustomerHeader model) async {
    final success = await _callApi<bool>(() => _service.updateCustomer(model));
    // The result is true only if the API call was successful and returned true.
    return success ?? false;
  }
}