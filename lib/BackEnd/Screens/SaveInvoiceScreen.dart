import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samaki_clinic/BackEnd/Model/ConsultationModel.dart';
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';
import 'package:samaki_clinic/BackEnd/Model/Product_Model.dart';
import 'package:samaki_clinic/BackEnd/Model/invoice_model.dart';
import 'package:samaki_clinic/BackEnd/Screens/Consultation_ListScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/CustomerList_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Product_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/daskboard_Screen.dart';
import 'package:samaki_clinic/BackEnd/Service/Invoice_service.dart';


class InvoiceItemController {
  final TextEditingController descriptionController;
  final TextEditingController qtyController;
  final TextEditingController unitPriceController;
  final ValueNotifier<double> lineTotalNotifier;

  InvoiceItemController()
      : descriptionController = TextEditingController(),
        qtyController = TextEditingController(text: '1'),
        unitPriceController = TextEditingController(text: '0.00'),
        lineTotalNotifier = ValueNotifier<double>(0.0);

  void calculateLineTotal() {
    final qty = int.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(unitPriceController.text) ?? 0.0;
    lineTotalNotifier.value = qty * price;
  }

  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    unitPriceController.dispose();
    lineTotalNotifier.dispose();
  }
}

class SaveInvoiceScreen extends StatefulWidget {
  final ConsultationModel? consultation;

  const SaveInvoiceScreen({Key? key, this.consultation}) : super(key: key);

  @override
  _SaveInvoiceScreenState createState() => _SaveInvoiceScreenState();
}

class _SaveInvoiceScreenState extends State<SaveInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final InvoiceService _invoiceService =
      InvoiceService(baseUrl: 'http://localhost:58691');

  final _invoiceNumberController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _customerController = TextEditingController();
  final _petController = TextEditingController();
  final _discountController = TextEditingController(text: '0.00');

  final List<InvoiceItemController> _itemControllers = [];

  late final ValueNotifier<double> _subTotalNotifier;
  late final ValueNotifier<double> _totalTaxNotifier;
  late final ValueNotifier<double> _grandTotalNotifier;
  bool _isLoading = false;
  int? _consultId;

  @override
  void initState() {
    super.initState();
    _subTotalNotifier = ValueNotifier<double>(0.0);
    _totalTaxNotifier = ValueNotifier<double>(0.0);
    _grandTotalNotifier = ValueNotifier<double>(0.0);

    _invoiceNumberController.text =
        "INV/25/${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    _dateTimeController.text =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    if (widget.consultation != null) {
      final header = widget.consultation!.header;
      _customerController.text = header.customerName;
      _petController.text = header.petName;
      _consultId = header.consultId;
    }

    for (int i = 0; i < 5; i++) {
      _addItem(calculate: false);
    }
    _calculateTotals();

    _discountController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _dateTimeController.dispose();
    _customerController.dispose();
    _petController.dispose();
    _discountController.removeListener(_calculateTotals);
    _discountController.dispose();
    _subTotalNotifier.dispose();
    _totalTaxNotifier.dispose();
    _grandTotalNotifier.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateTotals() {
    double currentSubTotal = 0.0;
    for (var controller in _itemControllers) {
      final qty = int.tryParse(controller.qtyController.text) ?? 0;
      final price = double.tryParse(controller.unitPriceController.text) ?? 0.0;
      currentSubTotal += qty * price;
    }
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    _subTotalNotifier.value = currentSubTotal;
    _totalTaxNotifier.value = 0.0;
    _grandTotalNotifier.value =
        (_subTotalNotifier.value + _totalTaxNotifier.value) - discount;
  }

  void _addItem({bool calculate = true}) {
    setState(() {
      _itemControllers.add(InvoiceItemController());
    });
    if (calculate) {
      _calculateTotals();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
      _calculateTotals();
    });
  }

  void _onItemChanged(InvoiceItemController controller) {
    controller.calculateLineTotal();
    _calculateTotals();
  }

  Future<void> _selectProductForItem(int index) async {
    final selectedProduct = await Navigator.push<ProductModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListView(isSelectionMode: true),
      ),
    );

    if (selectedProduct != null) {
      final itemController = _itemControllers[index];
      setState(() {
        itemController.descriptionController.text =
            selectedProduct.description ?? '';
        itemController.unitPriceController.text =
            selectedProduct.unitPrice?.toStringAsFixed(2) ?? '0.00';
      });
      _onItemChanged(itemController);
    }
  }

  // NEW: Method to handle selecting a customer or consultation
  Future<void> _selectCustomerOrConsultation() async {
    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Data Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('From Customer List'),
              onTap: () => Navigator.of(context).pop('customer'),
            ),
            ListTile(
              leading: const Icon(Icons.healing_outlined),
              title: const Text('From Consultation List'),
              onTap: () => Navigator.of(context).pop('consultation'),
            ),
          ],
        ),
      ),
    );

    if (source == 'customer') {
      final result = await Navigator.push<CustomerWithPets>(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerListViewScreen(isSelectionMode: true),
        ),
      );
      if (result != null) {
        setState(() {
          _customerController.text = result.header.fullName;
          _petController.text =
              result.detail.isNotEmpty ? result.detail.first.petName : '';
          _consultId = null; // Clear consult ID if selected from customer list
        });
      }
    } else if (source == 'consultation') {
      final result = await Navigator.push<ConsultationModel>(
        context,
        MaterialPageRoute(
          builder: (context) => const ConsultationScreen(isSelectionMode: true),
        ),
      );
      if (result != null) {
        setState(() {
          _customerController.text = result.header.customerName;
          _petController.text = result.header.petName;
          _consultId = result.header.consultId;
        });
      }
    }
  }


  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final validDetailsControllers = _itemControllers
        .where((c) => c.descriptionController.text.isNotEmpty)
        .toList();
    if (validDetailsControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Error: Please add at least one invoice item.'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    for (var controller in validDetailsControllers) {
      final qty = int.tryParse(controller.qtyController.text);
      final price = double.tryParse(controller.unitPriceController.text);
      if (qty == null || qty <= 0 || price == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error: Please enter a valid quantity and price for "${controller.descriptionController.text}".'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    }
    setState(() => _isLoading = true);
    try {
      final details = validDetailsControllers.map((c) {
        final qty = int.parse(c.qtyController.text);
        final unitPrice = double.parse(c.unitPriceController.text);
        return InvoiceDetail(
          invoiceDetailId: 0,
          invoiceId: 0,
          productId: 0,
          code: 'N/A',
          description: c.descriptionController.text,
          qty: qty,
          unitPrice: unitPrice,
          lineTotal: qty * unitPrice,
        );
      }).toList();
      final header = InvoiceHeader(
        invoiceId: 0,
        consultId: _consultId ?? 0,
        customerId: 0,
        customerName: _customerController.text,
        phone: _petController.text,
        invoiceNumber: _invoiceNumberController.text,
        invoiceDate:
            DateFormat('dd/MM/yyyy HH:mm').parse(_dateTimeController.text),
        subTotal: _subTotalNotifier.value,
        tax: _totalTaxNotifier.value,
        discount: double.tryParse(_discountController.text) ?? 0.0,
        grandTotal: _grandTotalNotifier.value,
        paymentStatus: 'Yes',
        note: 'Payment Term:',
        createDate: DateTime.now(),
      );
      final response = await _invoiceService
          .postInvoice(Invoice(header: header, detail: details));
          
      if (mounted && response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invoice Saved Successfully!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardPage(initialIndex: 3),
          ),
          (Route<dynamic> route) => false,
        );

      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create New Invoice',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      margin: const EdgeInsets.only(right: 4.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.receipt,
                                  color: Colors.indigo[700], size: 18),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('Invoice Details',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo[700])),
                              ),
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: _buildCompactFormField(
                                label: 'Invoice No',
                                controller: _invoiceNumberController,
                                icon: Icons.numbers,
                                readOnly: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: _buildCompactFormField(
                                label: 'Date & Time',
                                controller: _dateTimeController,
                                icon: Icons.calendar_today,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Card(
                      margin: const EdgeInsets.only(left: 4.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.person_outline,
                                  color: Colors.indigo[700], size: 18),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text('Customer Info',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo)),
                                ),
                              ),
                              // NEW: Search button for customer/consultation
                              IconButton(
                                icon: const Icon(Icons.search, size: 20),
                                tooltip: 'Find Customer or Consultation',
                                onPressed: _selectCustomerOrConsultation,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: _buildCompactFormField(
                                label: 'Customer Name',
                                controller: _customerController,
                                icon: Icons.person,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: _buildCompactFormField(
                                label: 'Pet',
                                controller: _petController,
                                icon: Icons.pets,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // The rest of the build method is unchanged
              Card(
                margin: const EdgeInsets.only(top: 12.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(children: [
                        Icon(Icons.list_alt,
                            color: Colors.indigo[700], size: 18),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Invoice Items',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo[700])),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: _buildCompactTableHeader(),
                      ),
                      ..._itemControllers.asMap().entries.map((entry) {
                        return _buildCompactItemRow(entry.value, entry.key);
                      }).toList(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item'),
                          onPressed: _addItem,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.indigo[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.calculate,
                                    color: Colors.indigo[700], size: 18),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text('Invoice Summary',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo[700])),
                                ),
                              ]),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: _buildCompactTotalRow(
                                    'Subtotal:', _subTotalNotifier),
                              ),
                              const Divider(height: 1),
                              _buildCompactTotalRow('Tax:', _totalTaxNotifier),
                              const Divider(height: 1),
                              _buildCompactDiscountField(),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: _buildCompactTotalRow(
                                  'GRAND TOTAL:',
                                  _grandTotalNotifier,
                                  isGrandTotal: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _saveInvoice,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                      Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Save Invoice',
                                            style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 16, color: Colors.indigo[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        isDense: true,
      ),
    );
  }

  Widget _buildCompactTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          const Expanded(
              flex: 5,
              child: Text('Description',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo))),
          const Expanded(
              flex: 1,
              child: Text('Qty',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo),
                  textAlign: TextAlign.center)),
          const Expanded(
              flex: 2,
              child: Text('Price',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo),
                  textAlign: TextAlign.right)),
          const Expanded(
              flex: 2,
              child: Text('Total',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo),
                  textAlign: TextAlign.right)),
          Container(width: 30),
        ],
      ),
    );
  }

  Widget _buildCompactItemRow(InvoiceItemController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: controller.descriptionController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Select or type item...',
                isDense: true,
                contentPadding:
                    const EdgeInsets.only(left: 8, right: 4, top: 10, bottom: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  padding: EdgeInsets.zero,
                  onPressed: () => _selectProductForItem(index),
                )
              ),
              onChanged: (_) => _onItemChanged(controller),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                controller: controller.qtyController,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
                onChanged: (_) => _onItemChanged(controller),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller.unitPriceController,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
              onChanged: (_) => _onItemChanged(controller),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ValueListenableBuilder<double>(
                valueListenable: controller.lineTotalNotifier,
                builder: (context, lineTotal, child) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '\$${lineTotal.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 18, color: Colors.red[400]),
            onPressed: () => _removeItem(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTotalRow(
      String label, ValueNotifier<double> valueNotifier,
      {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 13 : 12,
              fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w500,
              color: isGrandTotal ? Colors.indigo[700] : Colors.grey[700],
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: valueNotifier,
            builder: (context, value, child) {
              return Text(
                '\$${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isGrandTotal ? 14 : 13,
                  fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w500,
                  color: isGrandTotal ? Colors.indigo[700] : Colors.black87,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCompactDiscountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discount:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700]),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _discountController,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}