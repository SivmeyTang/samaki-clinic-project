// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';

// Future<void> exportInvoicesToExcel(List<List<dynamic>> data, String fileName) async {
//   // Create a new Excel document
//   final excel = Excel.createExcel();
//   final sheet = excel['Sheet1'];

//   // Append all rows
//  for (var row in data) {
//   if (row != null && row.isNotEmpty) {
//     sheet.appendRow(row.map((e) => e.toString()).toList());
//   }
// }





//   // Get the directory to save the file
//   Directory? directory;
//   if (Platform.isAndroid) {
//     directory = await getExternalStorageDirectory();
//     // NOTE: Make sure you have WRITE_EXTERNAL_STORAGE permission on Android
//   } else {
//     directory = await getApplicationDocumentsDirectory();
//   }

//   final filePath = '${directory!.path}/$fileName.xlsx';

//   // Save the file
//   final fileBytes = excel.encode();
//   if (fileBytes != null) {
//     final file = File(filePath);
//     await file.writeAsBytes(fileBytes, flush: true);
//     print('Excel file saved at: $filePath');
//   }
// }

// // Example usage (call this in a widget or your app's logic)
// Future<void> example() async {
//   List<dynamic> headers = [
//     'Invoice No',
//     'Date',
//     'Customer',
//     'Total'
//   ];

//   List<List<dynamic>> rows = [
//     headers,
//     ['INV-001', '2025-08-10', 'John Doe', '99.50'],
//     ['INV-002', '2025-08-09', 'Jane Smith', '150.00'],
//   ];

//   await exportInvoicesToExcel(rows, 'Invoices');
// }
