import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';


// --- Your existing imports ---
import 'package:samaki_clinic/BackEnd/Model/invoice_model.dart';
import 'package:samaki_clinic/BackEnd/Screens/SaveInvoiceScreen.dart';
import 'package:samaki_clinic/BackEnd/Service/Invoice_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late Future<InvoiceResponse> futureInvoices;
  final InvoiceService service =
      InvoiceService(baseUrl: 'http://localhost:58691');

  @override
  void initState() {
    super.initState();
    _refreshInvoices();
  }

  void _refreshInvoices() {
    setState(() {
      futureInvoices = service.getAllInvoices().then((response) {
        // Sorts invoices by date, newest first
        response.data.sort(
          (a, b) => b.header.invoiceDate.compareTo(a.header.invoiceDate),
        );
        return response;
      });
    });
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SaveInvoiceScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      _refreshInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: AppBar(
            leading: const Icon(Icons.pets),
            title: const Text(
              'Invoices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                color: Colors.white,
                tooltip: 'Create New Invoice',
                onPressed: _navigateAndRefresh,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<InvoiceResponse>(
        future: futureInvoices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(
              child: Text(
                'No invoices found',
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(4.0),
            itemCount: snapshot.data!.data.length,
            itemBuilder: (context, index) {
              final invoice = snapshot.data!.data[index];
              return _InvoiceCard(invoice: invoice);
            },
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = invoice.header;
    final details = invoice.detail;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      shadowColor: Colors.blue.withOpacity(0.3),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedIconColor: Colors.blue[800],
        iconColor: Colors.blue[800],
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.receipt_long, color: Colors.blue, size: 20),
        ),
        title: Text(
          'Invoice #${header.invoiceNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          header.customerName,
          style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${header.grandTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue[800],
              ),
            ),
            _StatusBadge(status: header.paymentStatus),
          ],
        ),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderDetails(header),
                const Divider(height: 10.0, color: Colors.blueGrey),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 2),
                ...details.map((item) => _buildItemRow(item)).toList(),
                const Divider(height: 10.0, color: Colors.blueGrey),
                _buildFinancialsSection(header),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.print_outlined, color: Colors.blue[700]),
                      label: Text(
                        'Print',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                      onPressed: () => _generateAndPrintInvoice(context, invoice),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.save_alt, color: Colors.blue[700]),
                      label: Text(
                        'Save PDF',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                      onPressed: () => _savePdfToFile(context, invoice),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
Future<void> _generateAndPrintInvoice(BuildContext context, Invoice invoice) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Check printing capabilities
    final PrintingInfo printingInfo = await Printing.info();
    
    if (!printingInfo.canPrint) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printing not available on this device')),
      );
      return;
    }

    // Generate PDF
    final Uint8List pdfBytes = await _generatePdf(invoice);
    
    if (pdfBytes.isEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF')),
      );
      return;
    }

    // Hide loading indicator
    Navigator.of(context, rootNavigator: true).pop();

    // Open print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${invoice.header.invoiceNumber}',
      format: PdfPageFormat.a5,
    );
  } catch (e) {
    // Hide loading indicator if there's an error
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    debugPrint('Printing error: $e');
  }
}
Future<void> _savePdfToFile(BuildContext context, Invoice invoice) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Generate PDF bytes
    final Uint8List pdfBytes = await _generatePdf(invoice);
    
    if (pdfBytes.isEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF')),
      );
      return;
    }

    // Get the downloads directory (works on both Android and iOS)
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // On Android, we need to use a specific subdirectory
        String newPath = '${directory!.path}/Download';
        directory = Directory(newPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error getting directory: $e');
      directory = await getApplicationDocumentsDirectory();
    }

    // Create file name with timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = 'Invoice_${invoice.header.invoiceNumber}_$timestamp.pdf';
    final String filePath = '${directory!.path}/$fileName';

    // Write the file
    final File file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    // Verify file was written
    if (!await file.exists()) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save PDF file')),
      );
      return;
    }

    // Hide loading indicator
    Navigator.of(context, rootNavigator: true).pop();

    // Open the file to confirm it worked
    final result = await OpenFile.open(file.path);
    
    // Show result to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message == 'Done' 
          ? 'PDF saved to: ${file.path}'
          : 'PDF saved but could not open: ${result.message}'),
        duration: const Duration(seconds: 3),
      ),
    );

  } catch (e) {
    // Hide loading indicator if there's an error
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving file: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    debugPrint('File save error: $e');
  }
}
  Future<Uint8List> _generatePdf(Invoice invoice) async {
    try {
      final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
      final header = invoice.header;
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      // Load fonts
      final pw.Font baseFont = await PdfGoogleFonts.robotoRegular();
      pw.Font? khmerFont;
      
      try {
        final fontData = await rootBundle.load('assets/fonts/KhmerOS_siemreap.ttf');
        khmerFont = pw.Font.ttf(fontData);
      } catch (e) {
        debugPrint('Khmer font not found, using fallback: $e');
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          theme: pw.ThemeData.withFont(
            base: khmerFont ?? baseFont,
          ),
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Clinic header
                  pw.Center(
                    child: pw.Text(
                      'SAMAKI VETERINARY CLINIC',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      '016 476 971 / 078 467 971',
                      style: pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 10),

                  // Invoice info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('លេខវិក្កយបត្រ/Invoice N°: ${header.invoiceNumber}'),
                          pw.Text('កាលបរិច្ឆេទ/Date: ${dateFormat.format(header.invoiceDate)}'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('អតិថិជន/Customer: ${header.customerName}'),
                          pw.Text('សត្វ/Pet: Cat 3Kg'), // Example data
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Items table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(4),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('បរិយាយ/Description', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('បរិមាណ\nQty', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('តម្លៃ\nPrice', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('សរុប\nTotal', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right),
                          ),
                        ],
                      ),
                      // Item rows
                      ...invoice.detail.map((item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.description),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.qty.toString(),
                              textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('\$${item.lineTotal.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right),
                          ),
                        ],
                      )).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Totals section
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildPdfTotalRow('សរុប / Total:', header.subTotal),
                        _buildPdfTotalRow('សរុបពន្ធ / Total Tax:', header.tax),
                        _buildPdfTotalRow('បញ្ចុះតម្លៃ / Discount:', header.discount),
                        pw.Divider(height: 5, thickness: 1),
                        _buildPdfTotalRow('ទឹកប្រាក់សរុប / Grand Total:', 
                          header.grandTotal, isTotal: true),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.Center(
                    child: pw.Text(
                      'Thank you for your business!',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      return doc.save();
    } catch (e) {
      debugPrint('PDF generation error: $e');
      return Uint8List(0); // Return empty bytes on error
    }
  }

  pw.Widget _buildPdfTotalRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            '\$${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDetails(InvoiceHeader header) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: Colors.blueGrey[500]),
        const SizedBox(width: 2),
        Text(
          'Date: ${header.invoiceDate.toString().split(' ')[0]}',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.blueGrey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(InvoiceDetail item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.description,
              style: TextStyle(color: Colors.blueGrey[800], fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.qty} x \$${item.unitPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${item.lineTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialsSection(InvoiceHeader header) {
    return Column(
      children: [
        _buildFinancialsRow('Subtotal:', header.subTotal),
        _buildFinancialsRow('Tax:', header.tax),
        _buildFinancialsRow('Discount:', header.discount),
        const Divider(height: 8, thickness: 1, color: Colors.blueGrey),
        _buildFinancialsRow('Grand Total:', header.grandTotal, isTotal: true),
      ],
    );
  }

  Widget _buildFinancialsRow(String label, double amount,
      {bool isTotal = false}) {
    final style = TextStyle(
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      fontSize: isTotal ? 13 : 12,
      color: isTotal ? Colors.blue[800] : Colors.blueGrey[800],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: style.copyWith(
              color: isTotal ? Colors.blue[800] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    String text = status;

    switch (status.toLowerCase()) {
      case 'yes':
        color = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Paid';
        break;
      case 'no':
        color = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = 'Unpaid';
        break;
      default:
        color = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}