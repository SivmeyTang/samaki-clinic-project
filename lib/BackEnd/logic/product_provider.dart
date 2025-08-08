import 'package:flutter/foundation.dart';
import 'package:samaki_clinic/BackEnd/Model/PostProduct_Model.dart';
import 'package:samaki_clinic/BackEnd/Model/Product_Model.dart';
import 'package:samaki_clinic/BackEnd/Service/Product_servive.dart';


class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _rowsPerPage = 15;
  int _currentPage = 0;
  String? _sortColumn;
  bool _sortAscending = false;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get rowsPerPage => _rowsPerPage;
  int get currentPage => _currentPage;
  int get totalPages =>
      _filteredProducts.isEmpty ? 1 : (_filteredProducts.length / _rowsPerPage).ceil();

  /// **IMPROVED**: Reusable private method for robust duplicate checking.
  /// It's case-insensitive, trims whitespace, and can exclude a specific product ID during checks (essential for updates).
  bool _isCodeDuplicate(String code, {int? excludeProductId}) {
    final normalizedCode = code.trim().toLowerCase();
    if (normalizedCode.isEmpty) return false; // Don't flag empty codes

    return _products.any((p) {
      // If we are updating, skip checking the product against itself
      if (p.productId == excludeProductId) {
        return false;
      }
      // Perform a case-insensitive and trimmed comparison
      return p.code?.trim().toLowerCase() == normalizedCode;
    });
  }

  // Fetch products from backend
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
      _sortColumn = 'createDate';
      _sortAscending = false;
      _applyFilterAndSort();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Post product to backend with duplicate prevention
  Future<bool> postProduct(PostProduct product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // **IMPROVED**: Use the robust, reusable duplicate check method.
      if (_isCodeDuplicate(product.code!)) {
        _errorMessage = "Product with code '${product.code}' already exists.";
        return false;
      }

      final success = await _productService.postProduct(product);
      if (success) {
        await fetchProducts(); // Refresh list on success
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to post product: $e';
      return false;
    } finally {
      _isLoading = false;
      // This check prevents an error if the widget is disposed before the future completes.
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  // Update product
  Future<bool> updateProduct(int id, ProductModel updatedProduct) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // **IMPROVED**: Added duplicate check for updates, excluding the product being edited.
      if (_isCodeDuplicate(updatedProduct.code!, excludeProductId: id)) {
        _errorMessage = "Product code '${updatedProduct.code}' is already used by another product.";
        return false;
      }

      final success = await _productService.updateProduct(id, updatedProduct.toJson());
      if (success) {
        // Instead of a full refetch, just update the local list for faster UI response.
        final index = _products.indexWhere((product) => product.productId == id);
        if (index != -1) {
          _products[index] = updatedProduct;
          _applyFilterAndSort(); // Re-apply filters and sorting
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _productService.deleteProduct(id);
      if (success) {
        _products.removeWhere((product) => product.productId == id);
        _applyFilterAndSort();
      } else {
        _errorMessage = 'Failed to delete product';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _currentPage = 0;
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    // Filter
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        final query = _searchQuery.toLowerCase();
        return (product.description ?? '').toLowerCase().contains(query) ||
            (product.code ?? '').toLowerCase().contains(query) ||
            (product.type ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    if (_sortColumn != null) {
      _filteredProducts.sort((a, b) {
        final valueA = _getSortValue(a, _sortColumn!);
        final valueB = _getSortValue(b, _sortColumn!);

        if (valueA == null && valueB == null) return 0;
        if (valueA == null) return 1;
        if (valueB == null) return -1;

        final comparison = valueA.compareTo(valueB);
        return _sortAscending ? comparison : -comparison;
      });
    }
  }

  Comparable _getSortValue(ProductModel product, String columnName) {
    switch (columnName) {
      case 'code':
        return product.code?.toLowerCase() ?? ''; // Sort case-insensitively
      case 'description':
        return product.description?.toLowerCase() ?? '';
      case 'qty':
        return product.qty ?? 0;
      case 'unitPrice':
        return product.unitPrice ?? 0;
      case 'costPrice':
        return product.costPrice ?? 0;
      case 'createDate':
        return product.createDate ?? DateTime(1900);
      case 'UpdateDate':
        return product.UpdateDate ?? DateTime(1900);
      case 'status':
        return product.status?.toLowerCase() ?? '';
      case 'type':
        return product.type?.toLowerCase() ?? '';
      case 'expireDate':
        return product.expireDate ?? DateTime(1900);
      default:
        return '';
    }
  }

  void sort(String columnName) {
    if (_sortColumn == columnName) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = columnName;
      _sortAscending = true;
    }
    _applyFilterAndSort();
    notifyListeners();
  }

  // --- PAGINATION ---
  void setRowsPerPage(int value) {
    _rowsPerPage = value;
    _currentPage = 0;
    notifyListeners();
  }

  void goToPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }
}