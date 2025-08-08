import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'dart:async';
import 'package:data_table_2/data_table_2.dart';
import 'package:samaki_clinic/BackEnd/Model/Product_Model.dart';
import 'package:samaki_clinic/BackEnd/Screens/PostProductForm_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/UpdateProductForm.dart';
import 'package:samaki_clinic/BackEnd/logic/product_provider.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).setSearchQuery(_searchController.text);
    });
  }

  // NEW: Helper function to show the full description in a dialog.
  Future<void> _showFullDescriptionDialog(
      BuildContext context, String description) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Full Description'),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns(ProductProvider provider) {
    return [
      DataColumn2(
        label: _buildHeaderText('Code'),
        onSort: (columnIndex, ascending) => provider.sort('code'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: _buildHeaderText('Description'),
        onSort: (columnIndex, ascending) => provider.sort('description'),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: _buildHeaderText('Type'),
        onSort: (columnIndex, ascending) => provider.sort('type'),
      ),
      DataColumn2(
        label: _buildHeaderText('Qty'),
        numeric: true,
        onSort: (columnIndex, ascending) => provider.sort('qty'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: _buildHeaderText('Unit Price'),
        numeric: true,
        onSort: (columnIndex, ascending) => provider.sort('unitPrice'),
      ),
      DataColumn2(
        label: _buildHeaderText('Cost Price'),
        numeric: true,
        onSort: (columnIndex, ascending) => provider.sort('costPrice'),
      ),
      DataColumn2(
        label: _buildHeaderText('Status'),
        onSort: (columnIndex, ascending) => provider.sort('status'),
      ),
      DataColumn2(
        label: _buildHeaderText('Create Date'),
        onSort: (columnIndex, ascending) => provider.sort('createDate'),
      ),
      DataColumn2(
        label: _buildHeaderText('Update Date'),
        onSort: (columnIndex, ascending) => provider.sort('UpdateDate'),
      ),
      DataColumn2(
        label: _buildHeaderText('Expiry'),
        onSort: (columnIndex, ascending) => provider.sort('expireDate'),
      ),
      const DataColumn2(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildDataRows(
    List<ProductModel> products,
    int rowsPerPage,
    int currentPage,
    ProductProvider provider,
  ) {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage).clamp(0, products.length);

    if (startIndex >= products.length) {
      return [];
    }

    final paginatedProducts = products.sublist(startIndex, endIndex);

    return paginatedProducts.map((product) {
      final isExpired = product.expireDate?.isBefore(DateTime.now()) ?? false;
      final isLowStock = (product.qty ?? 0) < 10;
      final descriptionText = product.description ?? 'N/A';

      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
          (states) => paginatedProducts.indexOf(product) % 2 == 0
              ? Colors.white
              : Colors.grey.shade50,
        ),
        cells: [
          DataCell(
            Text(
              product.code ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          // MODIFIED: DataCell for Description is now clickable and truncated.
          DataCell(
            InkWell(
              onTap: () => _showFullDescriptionDialog(context, descriptionText),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Tooltip(
                  message: descriptionText,
                  child: Text(
                    descriptionText,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2, // Limit to 2 lines
                    overflow:
                        TextOverflow.ellipsis, // Add '...' if it overflows
                  ),
                ),
              ),
            ),
          ),
          DataCell(
            Text(product.type ?? 'N/A', style: const TextStyle(fontSize: 13)),
          ),
          DataCell(
            Center(
              child: Text(
                '${product.qty ?? 0}',
                style: TextStyle(
                  color: isLowStock ? Colors.orange.shade700 : null,
                  fontWeight: isLowStock ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              '\$${product.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text('\$${product.costPrice?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(product.status),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusBorderColor(product.status),
                  width: 1,
                ),
              ),
              child: Text(
                product.status ?? 'N/A',
                style: TextStyle(
                  color: _getStatusTextColor(product.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              DateFormat('MMM dd, yyyy').format(product.createDate),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          DataCell(
            Text(
              product.UpdateDate != null
                  ? DateFormat('MMM dd, yyyy').format(product.UpdateDate!)
                  : 'N/A',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          DataCell(
            Text(
              product.expireDate != null
                  ? DateFormat('MMM dd, yyyy').format(product.expireDate!)
                  : 'N/A',
              style: TextStyle(
                color: isExpired ? Colors.red.shade700 : Colors.grey.shade700,
                fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'Edit',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateProductForm(product: product),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                  tooltip: 'Delete',
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      context,
                      product.productId,
                      provider,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green.shade50;
      case 'inactive':
        return Colors.orange.shade50;
      case 'expired':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getStatusBorderColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green.shade100;
      case 'inactive':
        return Colors.orange.shade100;
      case 'expired':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green.shade800;
      case 'inactive':
        return Colors.orange.shade800;
      case 'expired':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildPaginationControls(ProductProvider provider) {
    final canGoBack = provider.currentPage > 0;
    final canGoForward =
        provider.currentPage < provider.totalPages - 1 &&
            provider.totalPages > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${provider.filteredProducts.isEmpty ? 0 : provider.currentPage * provider.rowsPerPage + 1}-${(provider.currentPage + 1) * provider.rowsPerPage > provider.filteredProducts.length ? provider.filteredProducts.length : (provider.currentPage + 1) * provider.rowsPerPage} of ${provider.filteredProducts.length} products',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Row(
            children: [
              DropdownButton<int>(
                value: provider.rowsPerPage,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                items: [10, 15, 25, 50, 100].map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '$value items',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  provider.setRowsPerPage(value!);
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: canGoBack ? Colors.blue.shade600 : Colors.grey,
                ),
                onPressed: canGoBack ? () => provider.previousPage() : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${provider.currentPage + 1}',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                ' of ${provider.totalPages}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoForward ? Colors.blue.shade600 : Colors.grey,
                ),
                onPressed: canGoForward ? () => provider.nextPage() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading product inventory...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Failed to load products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductProvider>(
                context,
                listen: false,
              ).fetchProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'No products match your search'
                : 'Your product inventory is empty',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (isSearching)
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                // This will trigger the listener and clear the search
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear search',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
          if (!isSearching)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostProductForm(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    int productId,
    ProductProvider provider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this product?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.deleteProduct(productId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by code, description, or type...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue.shade400),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostProductForm(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            provider.fetchProducts();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add Product',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              if (provider.isLoading && provider.filteredProducts.isEmpty)
                Expanded(child: _buildLoadingState())
              else if (provider.errorMessage != null)
                Expanded(child: _buildErrorState(provider.errorMessage!))
              else if (provider.filteredProducts.isEmpty)
                Expanded(
                  child: _buildEmptyState(provider.searchQuery.isNotEmpty),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: DataTable2(
                              columnSpacing: 20,
                              horizontalMargin: 16,
                              headingRowHeight: 48,
                              dataRowHeight: 60, // Increased row height
                              columns: _buildDataColumns(provider),
                              rows: _buildDataRows(
                                provider.filteredProducts,
                                provider.rowsPerPage,
                                provider.currentPage,
                                provider,
                              ),
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.grey.shade100),
                              dividerThickness: 0.5,
                              showCheckboxColumn: false,
                            ),
                          ),
                        ),
                      ),
                      _buildPaginationControls(provider),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}