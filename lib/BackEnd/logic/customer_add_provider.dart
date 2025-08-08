import 'package:flutter/material.dart';
import '../Model/customer_add_model.dart';
import '../Service/customer_add_service.dart';

class CustomerAddProvider extends ChangeNotifier {
  final CustomerAddService _service = CustomerAddService();
  bool isLoading = false;
  String? error;
  bool _isCustomerAddedSuccessfully = false;

  bool get isCustomerAddedSuccessfully => _isCustomerAddedSuccessfully;

  Future<bool> addCustomer(CustomerRequestModel model) async {
    isLoading = true;
    _isCustomerAddedSuccessfully = false; // Reset success state
    notifyListeners();

    final success = await _service.saveCustomer(model);
    isLoading = false;
    notifyListeners();

    if (success) {
      _isCustomerAddedSuccessfully = true;
    } else {
      error = "Failed to save customer";
    }

    return success;
  }

  // Method to clear the error message
  void clearError() {
    error = null;
    notifyListeners();
  }

  // Method to reset the success state
  void resetSuccessState() {
    _isCustomerAddedSuccessfully = false;
    notifyListeners();
  }
}