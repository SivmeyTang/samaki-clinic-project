import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';
import 'package:samaki_clinic/BackEnd/Screens/CreateAppointmentScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/EditAppointmentScreen.dart';
import 'package:samaki_clinic/BackEnd/logic/AppointmentProvider.dart';

// --- IMPORTS FOR EXPORT FUNCTIONALITY ---
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:permission_handler/permission_handler.dart';
// --------------------------------------------------------

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late final TextEditingController _searchController;
  bool _isSearching = false;

  final List<int> _availableRowsPerPage = const [10, 15, 25, 50, 100];
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() =>
        Provider.of<AppointmentProvider>(context, listen: false)
            .fetchAppointments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- CORRECTED AND IMPROVED EXPORT METHOD ---
  Future<void> _exportToExcel() async {
    // 1. Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
  
    // Handle case where permission is denied
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to export data.')),
        );
      }
      return;
    }
  
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final appointments = provider.appointments;
  
    if (appointments.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export.')),
        );
      }
      return;
    }
  
    // 2. Create Excel file and sheet
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Appointments'];
  
    // 3. Add Header Row using TextCellValue
    final List<String> headers = [
      'Appointment ID', 'Full Name', 'Pet Number', 'Species', 'Appointment Date',
      'Appointment Time', 'Appointment Type', 'Phone Number', 'Email', 'Status',
      'Details', 'Created Date', 'Updated Date'
    ];
    // Wrap headers in TextCellValue objects for compatibility with the new API
    sheetObject.appendRow(headers.map((header) => TextCellValue(header)).toList());
  
    // Style for the header
    var headerCellStyle = CellStyle(
      bold: true,
      
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
  
    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }
  
    // 4. Add Data Rows
    final dateFormatter = DateFormat('yyyy-MM-dd');
    for (final appointment in appointments) {
      // Wrap each piece of data in a CellValue object
      final List<CellValue> row = [
        TextCellValue(appointment.appointmentId?.toString() ?? 'N/A'),
        TextCellValue(appointment.fullName ?? 'N/A'),
        TextCellValue(appointment.petOfNumber ?? 'N/A'),
        TextCellValue(appointment.species ?? 'N/A'),
        TextCellValue(appointment.appointmentDate != null ? dateFormatter.format(appointment.appointmentDate!) : 'N/A'),
        TextCellValue(appointment.appointmentTime ?? 'N/A'),
        TextCellValue(appointment.appointmentType ?? 'N/A'),
        TextCellValue(appointment.phoneNumber ?? 'N/A'),
        TextCellValue(appointment.email ?? 'N/A'),
        TextCellValue(appointment.status ?? 'N/A'),
        TextCellValue(appointment.detail ?? 'N/A'),
        TextCellValue(appointment.createdDate != null ? dateFormatter.format(appointment.createdDate!) : 'N/A'),
        TextCellValue(appointment.updateDate != null ? dateFormatter.format(appointment.updateDate!) : 'N/A'),
      ];
      sheetObject.appendRow(row);
    }
  
    // 5. Save the file
    final fileBytes = excel.save(); // .save() is the modern API call
    if (fileBytes != null) {
      try {
        String fileName = 'Samaki_Clinic_Appointments_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(fileBytes),
          ext: 'xlsx',
          // Corrected typo from .microsoftExcel to .MICROSOFT_EXCEL
          mimeType: MimeType.microsoftExcel,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported successfully to $fileName')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving file: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.pets),
        title: _isSearching
            ? _buildSearchField()
            : const Text('Appointments', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create Appointment',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateAppointmentScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  Provider.of<AppointmentProvider>(context, listen: false).searchAppointments('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Export to Excel',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          setState(() => _isSearching = false);
          await Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments();
        },
        child: Consumer<AppointmentProvider>(
          builder: (context, appointmentProvider, child) {
            if (appointmentProvider.isLoading && appointmentProvider.appointments.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
              );
            }

            if (appointmentProvider.error != null) {
              return _buildErrorState(context, appointmentProvider);
            }

            if (appointmentProvider.appointments.isEmpty && _searchController.text.isEmpty) {
              return _buildEmptyState(context, appointmentProvider);
            }

            return _buildAppointmentDataView(context, appointmentProvider);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search appointments...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<AppointmentProvider>(context, listen: false)
                      .searchAppointments('');
                },
              )
            : null,
      ),
      onChanged: (query) {
        Provider.of<AppointmentProvider>(context, listen: false)
            .searchAppointments(query);
      },
    );
  }

  Widget _buildAppointmentDataView(
      BuildContext context, AppointmentProvider provider) {
    final isSearching = _searchController.text.isNotEmpty;
    final appointmentDataSource =
        _AppointmentDataSource(provider.appointments, context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Card(
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dataTableTheme: DataTableThemeData(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.blue.shade50),
                    headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.shade100;
                      }
                      return null;
                    }),
                    dividerThickness: 0.5,
                  ),
                ),
                child: PaginatedDataTable2(
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: _availableRowsPerPage,
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? 10;
                    });
                  },
                  fixedLeftColumns: 1,
                  showCheckboxColumn: false,
                  minWidth: 2200,
                  empty: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          isSearching
                              ? 'No results found for "${_searchController.text}"'
                              : 'No appointments available',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                        if (isSearching) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.searchAppointments('');
                            },
                            child: const Text('Clear search'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  columns: const [
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('AppointmentId',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('FullName',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Pet_of_Number',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Species',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('AppointmentDate',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('AppointmentTime',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('AppointmentType',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('PhoneNumber',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Detail',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('CreatedDate',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('UpdateDate',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  source: appointmentDataSource,
                  columnSpacing: 20,
                  horizontalMargin: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, AppointmentProvider appointmentProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error: ${appointmentProvider.error ?? "Unknown error"}',
              style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => appointmentProvider.fetchAppointments(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppointmentProvider appointmentProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                color: Colors.grey.shade500, size: 60),
            const SizedBox(height: 16),
            const Text(
              'No appointments found',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => appointmentProvider.fetchAppointments(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentDataSource extends DataTableSource {
  final List<Appointment> _appointments;
  final BuildContext _context;

  _AppointmentDataSource(this._appointments, this._context);

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _navigateToEditScreen(Appointment appointment) {
    Navigator.of(_context).push(
      MaterialPageRoute(
        builder: (context) => EditAppointmentScreen(appointment: appointment),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          SizedBox(
            width: 100, // Aligns the values
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(
            child: valueWidget ??
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDialogContent(Appointment appointment) {
    final dateFormatter = DateFormat('EEEE, MMM dd, yyyy');
    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                Icons.person_outline, 'Full Name', appointment.fullName ?? ''),
            _buildDetailRow(
                Icons.pets_outlined, 'Pet Number', appointment.petOfNumber ?? ''),
            _buildDetailRow(
                Icons.category_outlined, 'Species', appointment.species ?? ''),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Date',
              appointment.appointmentDate != null
                  ? dateFormatter.format(appointment.appointmentDate!)
                  : '',
            ),
            _buildDetailRow(Icons.access_time_outlined, 'Time',
                appointment.appointmentTime ?? ''),
            _buildDetailRow(Icons.medical_services_outlined, 'Type',
                appointment.appointmentType ?? ''),
            _buildDetailRow(
              Icons.info_outline,
              'Status',
              '', // Value is provided by the custom widget
              valueWidget: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.phone_outlined, 'Phone',
                appointment.phoneNumber ?? ''),
            _buildDetailRow(Icons.email_outlined, 'Email', appointment.email ?? ''),
            _buildDetailRow(
                Icons.notes_outlined, 'Details', appointment.detail ?? ''),
          ],
        ),
      ),
    );
  }

  @override
  DataRow2? getRow(int index) {
    if (index >= _appointments.length) return null;
    final appointment = _appointments[index];

    final dateFormatter = DateFormat('MMM dd, yyyy');
    final formattedDate = appointment.appointmentDate != null
        ? dateFormatter.format(appointment.appointmentDate!)
        : 'N/A';

    final formattedCreatedDate = appointment.createdDate != null
        ? dateFormatter.format(appointment.createdDate!)
        : 'N/A';

    final formattedUpdateDate = appointment.updateDate != null
        ? dateFormatter.format(appointment.updateDate!)
        : 'N/A';

    String safeText(String? text) => text ?? '';

    return DataRow2(
      onSelectChanged: (isSelected) {
        if (isSelected != null && isSelected) {
          showDialog(
            context: _context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Appointment for ${appointment.fullName ?? 'N/A'}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800),
              ),
              content: _buildDetailDialogContent(appointment),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToEditScreen(appointment);
                  },
                ),
              ],
            ),
          );
        }
      },
      cells: [
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue.shade700),
                tooltip: 'Edit Appointment',
                onPressed: () {
                  _navigateToEditScreen(appointment);
                },
              ),
            ],
          ),
        ),
        DataCell(Text(
          appointment.appointmentId?.toString() ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        )),
        DataCell(Text(safeText(appointment.fullName))),
        DataCell(Text(safeText(appointment.petOfNumber))),
        DataCell(Text(safeText(appointment.species))),
        DataCell(Text(formattedDate)),
        DataCell(Text(safeText(appointment.appointmentTime))),
        DataCell(Text(safeText(appointment.appointmentType))),
        DataCell(Text(safeText(appointment.phoneNumber))),
        DataCell(Text(safeText(appointment.email))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appointment.status ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: appointment.detail ?? 'No details',
            child: Text(
              appointment.detail != null && appointment.detail!.length > 15
                  ? '${appointment.detail!.substring(0, 15)}...'
                  : safeText(appointment.detail),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(formattedCreatedDate)),
        DataCell(Text(formattedUpdateDate)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _appointments.length;

  @override
  int get selectedRowCount => 0;
}