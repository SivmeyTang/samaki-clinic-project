import 'package:flutter/material.dart';
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';
import 'package:samaki_clinic/BackEnd/Service/CustomerList_service.dart';


class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerWithPets> _allCustomers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _activeFilter = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;

  List<CustomerWithPets> get allCustomers => _allCustomers;

  List<CustomerWithPets> get filteredCustomers {
    List<CustomerWithPets> customers = List.from(_allCustomers);

    // Filter
    if (_activeFilter == 'With Pets') {
      customers = customers.where((c) => c.detail.isNotEmpty).toList();
    } else if (_activeFilter == 'No Pets') {
      customers = customers.where((c) => c.detail.isEmpty).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      customers = customers.where((c) {
        final header = c.header;
        return header.fullName.toLowerCase().contains(query) ||
            header.phone.toLowerCase().contains(query) ||
            header.email.toLowerCase().contains(query);
      }).toList();
    }

    return customers;
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allCustomers = await _customerService.getAllCustomers();
      _allCustomers.sort((a, b) => b.header.createDate.compareTo(a.header.createDate));
    } catch (e) {
      _errorMessage = 'Failed to fetch customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  /// ✅ This method was missing. It returns a customer with their pets by ID.
  Future<CustomerWithPets?> getCustomerWithPets(int customerId) async {
    if (_allCustomers.isEmpty) {
      await fetchCustomers(); // Load data if not already fetched
    }

    try {
      return _allCustomers.firstWhere((c) => c.header.customerId == customerId);
    } catch (e) {
      return null;
    }
  }
}
