import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/PostProduct_Model.dart';
import 'package:samaki_clinic/BackEnd/logic/product_provider.dart';


class PostProductForm extends StatefulWidget {
  const PostProductForm({super.key});

  @override
  State<PostProductForm> createState() => _PostProductFormState();
}

class _PostProductFormState extends State<PostProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();

  DateTime? _selectedExpireDate;
  String? _selectedType;

  // --- UI Design Constants ---
  static const Color _primaryColor = Color(0xFF3B82F6); // Blue-500
  static const Color _successColor = Color(0xFF10B981); // Emerald-500
  static const Color _errorColor = Color(0xFFEF4444); // Red-500
  static const Color _backgroundColor = Color(0xFFF9FAFB); // Gray-50
  static const Color _cardColor = Colors.white;
  static const Color _textColor = Color(0xFF1F2937); // Gray-800
  static const Color _labelColor = Color(0xFF6B7280); // Gray-500
  static const Color _borderColor = Color(0xFFE5E7EB); // Gray-200
  static const double _borderRadius = 12.0;

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _qtyController.dispose();
    _costPriceController.dispose();
    _unitPriceController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  // --- Core Logic Methods ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpireDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedExpireDate) {
      setState(() {
        _selectedExpireDate = picked;
        _expireDateController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  /// Handles form submission by calling the provider.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showFeedbackMessage(
          'Please correct the errors before saving.', isError: true);
      return;
    }

    // Use context.read to get the provider instance without listening
    final provider = context.read<ProductProvider>();

    final productToPost = PostProduct(
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      qty: int.tryParse(_qtyController.text.trim()) ?? 0,
      costPrice: double.tryParse(_costPriceController.text.trim()),
      unitPrice: double.tryParse(_unitPriceController.text.trim()),
      expireDate: _selectedExpireDate,
      type: _selectedType,
    );

    // Call the provider's postProduct method
    final isSuccess = await provider.postProduct(productToPost);

    if (!mounted) return;

    if (isSuccess) {
      _showFeedbackMessage('Product Added Successfully!', isError: false);

      // Delay pop slightly to allow message to show (optional)
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pop(context, true); // Return true to notify previous screen if needed
      });
    } else {
      // The provider now holds the error message
      _showFeedbackMessage(
          provider.errorMessage ?? 'Failed to post product. Please try again.',
          isError: true);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _codeController.clear();
    _descriptionController.clear();
    _qtyController.text = '1';
    _costPriceController.clear();
    _unitPriceController.clear();
    _expireDateController.clear();
    setState(() {
      _selectedExpireDate = null;
      _selectedType = null;
    });
  }

  void _showFeedbackMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? _errorColor : _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    // Watch the provider's isLoading state to disable buttons during submission
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return _buildWebLayout(isLoading);
            }
            return _buildMobileLayout(isLoading);
          },
        ),
      ),
    );
  }

  // --- Responsive Layout Builders ---

  Widget _buildWebLayout(bool isLoading) {
    return Column(
      children: [
        _buildWebAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 3,
                  child: _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Product Information',
                            'Enter the core details of the product.'),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _codeController,
                          label: 'Product Code / SKU',
                          icon: Icons.qr_code_2_outlined,
                          validator: (v) =>
                          v!.trim().isEmpty ? 'Product code is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.edit_outlined,
                          validator: (v) => v!.trim().isEmpty
                              ? 'Description is required'
                              : null,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Categorization', ''),
                            const SizedBox(height: 16),
                            _buildTypeDropdown(),
                            const SizedBox(height: 20),
                            _buildDateField(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Inventory & Pricing', ''),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _qtyController,
                              label: 'Quantity',
                              icon: Icons.inventory_2_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v!.trim().isEmpty) return 'Required';
                                if (int.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _costPriceController,
                                    label: 'Cost Price',
                                    icon: Icons.monetization_on_outlined,
                                    prefixText: '\$ ',
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    validator: (v) {
                                      if (v!.trim().isEmpty) return 'Required';
                                      if (double.tryParse(v.trim()) == null)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _unitPriceController,
                                    label: 'Unit Price',
                                    icon: Icons.sell_outlined,
                                    prefixText: '\$ ',
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    validator: (v) {
                                      if (v!.trim().isEmpty) return 'Required';
                                      if (double.tryParse(v.trim()) == null)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomActionBar(isLoading),
      ],
    );
  }

  Widget _buildMobileLayout(bool isLoading) {
    return Column(
      children: [
        _buildMobileAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Product Details', ''),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _codeController,
                        label: 'Product Code / SKU',
                        icon: Icons.qr_code_2_outlined,
                        validator: (v) =>
                        v!.trim().isEmpty ? 'Product code is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.edit_outlined,
                        validator: (v) => v!.trim().isEmpty
                            ? 'Description is required'
                            : null,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildTypeDropdown(),
                      const SizedBox(height: 20),
                      _buildDateField(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Inventory & Pricing', ''),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _qtyController,
                        label: 'Quantity',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _costPriceController,
                        label: 'Cost Price (\$)',
                        icon: Icons.monetization_on_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null)
                            return 'Invalid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _unitPriceController,
                        label: 'Unit Price (\$)',
                        icon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null)
                            return 'Invalid price';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomActionBar(isLoading),
      ],
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildWebAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      height: 70,
      decoration: const BoxDecoration(
        color: _cardColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_business_rounded, color: _primaryColor, size: 28),
          const SizedBox(width: 16),
          const Text(
            'Create New Product',
            style: TextStyle(
              color: _textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  AppBar _buildMobileAppBar() {
    return AppBar(
      title: const Text('New Product', style: TextStyle(color: _textColor)),
      backgroundColor: _cardColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: _textColor),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1, thickness: 1, color: _borderColor),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: _borderColor)),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: _labelColor,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBottomActionBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
      decoration: const BoxDecoration(
          color: _cardColor,
          border: Border(top: BorderSide(color: _borderColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isLoading ? null : _resetForm,
            style: TextButton.styleFrom(
              foregroundColor: _labelColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text(
              'Clear Form',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white),
            )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              isLoading ? 'SAVING...' : 'SAVE PRODUCT',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: _textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _labelColor),
        prefixIcon: Icon(icon, color: _labelColor, size: 20),
        prefixText: prefixText,
        filled: true,
        fillColor: _backgroundColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _expireDateController,
      readOnly: true,
      validator: (v) => _selectedType == 'Medical' && v!.isEmpty
          ? 'Expiry date is required for Medical items'
          : null,
      onTap: () => _selectDate(context),
      style: const TextStyle(color: _textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Expiry Date',
        hintText: 'Select a date',
        labelStyle: const TextStyle(color: _labelColor),
        prefixIcon:
        const Icon(Icons.calendar_today_outlined, color: _labelColor, size: 20),
        filled: true,
        fillColor: _backgroundColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      validator: (v) => v == null ? 'Please select a product type' : null,
      onChanged: (value) => setState(() => _selectedType = value),
      style: const TextStyle(
          color: _textColor, fontWeight: FontWeight.w500, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Product Type',
        labelStyle: const TextStyle(color: _labelColor),
        prefixIcon:
        const Icon(Icons.category_outlined, color: _labelColor, size: 20),
        filled: true,
        fillColor: _backgroundColor,
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Medicines', child: Text('Medicines')),
        DropdownMenuItem(value: 'Vaccines', child: Text('Vaccines')),
        DropdownMenuItem(value: 'Supplies', child: Text('Supplies')),
        DropdownMenuItem(value: 'Vaccines', child: Text('Vaccines')),
        
      ],
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
    );
  }
}