import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/ConsultationModel.dart';
import 'package:samaki_clinic/BackEnd/Screens/PostConsultationScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/SaveInvoiceScreen.dart';
import 'package:samaki_clinic/BackEnd/logic/consultation_provider.dart';

class ConsultationScreen extends StatefulWidget {
  // NEW: Add a flag to determine the mode of the screen.
  final bool isSelectionMode;

  const ConsultationScreen({super.key, this.isSelectionMode = false});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  ConsultationModel? _selectedConsultation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().fetchConsultations().then((_) {
        final provider = context.read<ConsultationProvider>();
        if (mounted &&
            (MediaQuery.of(context).size.width > 900) &&
            provider.filteredConsultations.isNotEmpty) {
          setState(() {
            provider.filteredConsultations
                .sort((a, b) => b.header.createDate.compareTo(a.header.createDate));
            _selectedConsultation = provider.filteredConsultations.first;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context
            .read<ConsultationProvider>()
            .setSearchQuery(_searchController.text);
      }
    });
  }

  void _navigateToCreateInvoice(ConsultationModel consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveInvoiceScreen(consultation: consultation),
        fullscreenDialog: true,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMM yyyy, hh:mm a').format(date);
  String _formatShortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.filteredConsultations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final consultations = provider.filteredConsultations;
          consultations
              .sort((a, b) => b.header.createDate.compareTo(a.header.createDate));

          if (consultations.isEmpty) {
            return _buildEmptyState(context, provider.searchQuery.isNotEmpty);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (_selectedConsultation != null &&
                  !consultations.contains(_selectedConsultation)) {
                _selectedConsultation =
                    consultations.isNotEmpty ? consultations.first : null;
              }
              // Don't auto-select in selection mode for web
              if (_selectedConsultation == null &&
                  constraints.maxWidth > 900 &&
                  consultations.isNotEmpty &&
                  !widget.isSelectionMode) {
                _selectedConsultation = consultations.first;
              }

              if (constraints.maxWidth > 900) {
                return _buildWebLayout(consultations);
              } else {
                return _buildMobileLayout(consultations);
              }
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: Icon(Icons.pets),
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by pet, owner, or phone...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14),
              ),
              style:
                  TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
            )
          // NEW: Title changes based on mode
          : Text(
              widget.isSelectionMode ? 'Select Consultation' : 'Consultation Records',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      actions: [
        // NEW: Hide 'Add' button in selection mode
        if (!widget.isSelectionMode)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'New Consultation',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddConsultationScreen())),
          ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, size: 22),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<ConsultationProvider>().setSearchQuery('');
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<ConsultationModel> consultations) {
    return RefreshIndicator(
      onRefresh: () => context.read<ConsultationProvider>().fetchConsultations(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
        itemCount: consultations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          return _buildMobileListItem(consultations[index]);
        },
      ),
    );
  }

  Widget _buildWebLayout(List<ConsultationModel> consultations) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: consultations.length,
              itemBuilder: (context, index) {
                final consultation = consultations[index];
                final isSelected = _selectedConsultation?.header.consultId ==
                    consultation.header.consultId;
                return _buildMasterListItem(consultation, isSelected);
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          // NEW: In selection mode, show a helpful message instead of details
          child: widget.isSelectionMode
              ? const Center(child: Text("Select a consultation from the list."))
              : _selectedConsultation != null
                  ? _buildDetailPanel(_selectedConsultation!)
                  : const Center(
                      child: Text("Select a consultation to view details.",
                          style: TextStyle(fontSize: 14))),
        ),
      ],
    );
  }

  Widget _buildMobileListItem(ConsultationModel consultation) {
    // NEW: In selection mode, show a simple tappable tile
    if (widget.isSelectionMode) {
      return Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          title: _buildHeaderSection(consultation.header, context),
          onTap: () {
            Navigator.of(context).pop(consultation);
          },
        ),
      );
    }

    // Normal mode shows the expandable tile
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: _buildHeaderSection(consultation.header, context),
        children: [_buildDetailContent(consultation)],
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildMasterListItem(ConsultationModel consultation, bool isSelected) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      color: isSelected
          ? theme.colorScheme.primary.withOpacity(0.08)
          : Colors.transparent,
      child: ListTile(
        // NEW: Updated onTap to handle both modes
        onTap: () {
          if (widget.isSelectionMode) {
            Navigator.of(context).pop(consultation);
          } else {
            setState(() => _selectedConsultation = consultation);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: _buildHeaderSection(consultation.header, context),
      ),
    );
  }

  Widget _buildDetailPanel(ConsultationModel consultation) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: _buildDetailContent(consultation),
      ),
    );
  }

  Widget _buildDetailContent(ConsultationModel consultation) {
    final header = consultation.header;
    final details = consultation.detail;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(title: "Record Dates", children: [
          _buildFormRow(
              label: "Posting Date",
              value: _formatDate(header.postingDate),
              icon: Icons.date_range_outlined),
          _buildFormRow(
              label: "Created On",
              value: _formatDate(header.createDate),
              icon: Icons.timer_outlined),
        ]),
        const SizedBox(height: 8),
        _buildFormSection(title: "General Information", children: [
          _buildFormRow(
              label: "Customer Name",
              value: header.customerName,
              icon: Icons.person_outline),
          _buildFormRow(
              label: "Phone",
              value: header.phone.trim(),
              icon: Icons.phone_outlined),
          _buildFormRow(
              label: "Pet Name",
              value: header.petName,
              icon: Icons.pets_outlined),
          _buildFormRow(
              label: "Species/Breed",
              value: '${header.species}/${header.breed}',
              icon: Icons.category_outlined),
          _buildFormRow(
              label: "Gender",
              value: header.gender,
              icon: header.gender.toLowerCase() == 'male'
                  ? Icons.male
                  : Icons.female),
        ]),
        const SizedBox(height: 8),
        _buildFormSection(title: "Medical Notes", children: [
          Text(
            header.historiesTreatment.isNotEmpty
                ? header.historiesTreatment
                : "No medical notes provided.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5, fontSize: 13),
          ),
        ]),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildFormSection(title: "Immunization Records", children: [
            _buildImmunizationTable(details, context),
          ]),
        ],
        // NEW: Hide 'Create Invoice' button in selection mode
        if (!widget.isSelectionMode) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.request_quote_outlined, size: 18),
              label: const Text('Create Invoice'),
              onPressed: () => _navigateToCreateInvoice(consultation),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderSection(ConsultationHeader header, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt_long_outlined,
              size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                header.petName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                header.customerName,
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 1),
              Text(
                header.phone.trim(),
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
      {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary)),
          const Divider(height: 12, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormRow(
      {required String label, required String value, required IconData icon}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.8)),
          const SizedBox(width: 8),
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.7)))),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmunizationTable(
      List<ImmunizationDetail> details, BuildContext context) {
    final theme = Theme.of(context);

    Widget buildTableRow(String type, String given, String next, String notify,
        {bool isHeader = false}) {
      final style = TextStyle(
        fontSize: 13,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        color: isHeader
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withOpacity(0.8),
      );

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isHeader
                  ? Colors.transparent
                  : theme.dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(type, style: style)),
            Expanded(flex: 2, child: Text(given, style: style)),
            Expanded(flex: 2, child: Text(next, style: style)),
            Expanded(flex: 2, child: Text(notify, style: style)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
          ),
          child: buildTableRow("Type", "Given", "Next", "Notify", isHeader: true),
        ),
        ...details.map((detail) {
          return buildTableRow(
            detail.immunizationType,
            _formatShortDate(detail.givenDate),
            _formatShortDate(detail.nextDueDate),
            _formatShortDate(detail.notifyDate),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.folder_off_outlined,
              size: 50, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            isSearching ? 'No Matching Consultations' : 'No Consultations Found',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            widget.isSelectionMode 
                ? 'No consultations found to select from.'
                : isSearching
                    ? 'Try a different search term.'
                    : 'Press the + button to add a consultation.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}