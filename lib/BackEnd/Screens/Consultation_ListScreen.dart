import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/ConsultationModel.dart';
import 'package:samaki_clinic/BackEnd/Screens/PostConsultationScreen.dart';

import '../logic/consultation_provider.dart';


class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

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
        if (mounted && (MediaQuery.of(context).size.width > 900) && provider.filteredConsultations.isNotEmpty) {
          setState(() {
            provider.filteredConsultations.sort((a, b) => b.header.createDate.compareTo(a.header.createDate));
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
        context.read<ConsultationProvider>().setSearchQuery(_searchController.text);
      }
    });
  }

  String _formatDate(DateTime date) => DateFormat('d MMM yyyy, hh:mm a').format(date);
  String _formatShortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsultationScreen())),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Consultation', style: TextStyle(fontSize: 14))),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.filteredConsultations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final consultations = provider.filteredConsultations;
          consultations.sort((a, b) => b.header.createDate.compareTo(a.header.createDate));

          if (consultations.isEmpty) {
            return _buildEmptyState(context, provider.searchQuery.isNotEmpty);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (_selectedConsultation != null && !consultations.contains(_selectedConsultation)) {
                _selectedConsultation = consultations.isNotEmpty ? consultations.first : null;
              }
              if (_selectedConsultation == null && constraints.maxWidth > 900 && consultations.isNotEmpty) {
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
    final consultationProvider = context.read<ConsultationProvider>();
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
            )
          : const Text('Consultation Records', style: TextStyle(fontSize: 16)),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, size: 20),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                consultationProvider.setSearchQuery('');
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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: consultations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
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
          width: 350,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 60,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: ListView.builder(
              itemCount: consultations.length,
              itemBuilder: (context, index) {
                final consultation = consultations[index];
                final isSelected = _selectedConsultation?.header.consultId == consultation.header.consultId;
                return _buildMasterListItem(consultation, isSelected);
              },
            ),
          ),
        ),
        Expanded(
          child: _selectedConsultation != null
              ? _buildDetailPanel(_selectedConsultation!)
              : const Center(child: Text("Select a consultation", style: TextStyle(fontSize: 14))),
        ),
      ],
    );
  }

  Widget _buildMobileListItem(ConsultationModel consultation) {
     return Card(
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: _buildTileHeader(consultation.header, context),
        children: [_buildDetailContent(consultation)],
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildMasterListItem(ConsultationModel consultation, bool isSelected) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        onTap: () => setState(() => _selectedConsultation = consultation),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: _buildHeaderSection(consultation.header, context),
      ),
    );
  }

  Widget _buildDetailPanel(ConsultationModel consultation) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
        _buildFormSection(context, title: "General Information", children: [
          _buildFormRow(context, label: "Customer Name", value: header.customerName, icon: Icons.person_outline),
          _buildFormRow(context, label: "Phone", value: header.phone.trim(), icon: Icons.phone_outlined),
          _buildFormRow(context, label: "Pet Name", value: header.petName, icon: Icons.pets_outlined),
          _buildFormRow(context, label: "Species/Breed", value: '${header.species}/${header.breed}', icon: Icons.category_outlined),
          _buildFormRow(context, label: "Gender", value: header.gender, icon: header.gender.toLowerCase() == 'male' ? Icons.male : Icons.female),
        ]),
        const SizedBox(height: 16),
        _buildFormSection(context, title: "Medical Notes", children: [
          Text(
            header.historiesTreatment.isNotEmpty ? header.historiesTreatment : "No treatment notes provided.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ]),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFormSection(context, title: "Immunization Records", children: [
            _buildImmunizationTable(details, context),
          ]),
        ],
        const SizedBox(height: 16),
        _buildFormSection(context, title: "Record Dates", children: [
          _buildFormRow(context, label: "Posting Date", value: _formatDate(header.postingDate), icon: Icons.date_range_outlined),
          _buildFormRow(context, label: "Created On", value: _formatDate(header.createDate), icon: Icons.timer_outlined),
        ]),
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
          child: Icon(Icons.receipt_long_outlined, size: 16, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header.petName,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                header.customerName,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                header.phone,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTileHeader(ConsultationHeader header, BuildContext context) {
    return _buildHeaderSection(header, context);
  }

  Widget _buildFormSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormRow(BuildContext context, {required String label, required String value, required IconData icon, bool multiLine = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
         ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              maxLines: multiLine ? 10 : 1,
              overflow: multiLine ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmunizationTable(List<ImmunizationDetail> details, BuildContext context) {
  final theme = Theme.of(context);
  return Card(
    elevation: 3,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          theme.colorScheme.primary.withOpacity(0.1),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return theme.colorScheme.primary.withOpacity(0.2);
            }
            return null; // default
          },
        ),
        columns: const [
          DataColumn(
            label: Text(
              "Type",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              "Given Date",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              "Next Date",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              "Notify Date",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: details.map(
          (detail) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    detail.immunizationType,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DataCell(
                  Text(
                    _formatShortDate(detail.givenDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DataCell(
                  Text(
                    _formatShortDate(detail.nextDueDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DataCell(
                  Text(
                    _formatShortDate(detail.notifyDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            );
          },
        ).toList(),
        columnSpacing: 20,
        horizontalMargin: 16,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
      ),
    ),
  );
}

  
  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.folder_off_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(isSearching ? 'No matching consultations' : 'No Consultations', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(isSearching ? 'Try a different search term' : 'Add your first consultation', 
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }
}