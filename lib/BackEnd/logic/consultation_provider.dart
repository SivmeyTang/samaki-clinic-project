// consultation_provider.dart

import 'package:flutter/material.dart';
import 'package:samaki_clinic/BackEnd/Model/ConsultationModel.dart';
import 'package:samaki_clinic/BackEnd/Service/consultation_service.dart';

// Enum to define the types of date filters available.
enum DateFilterType { allTime, today, last7Days, thisMonth, custom }

class ConsultationProvider with ChangeNotifier {
  final ClinicService service = ClinicService();
  List<ConsultationModel> _allConsultations = [];
  List<ConsultationModel> _filteredConsultations = [];
  List<ConsultationModel> get filteredConsultations => _filteredConsultations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // --- NEW: State for date filtering ---
  DateFilterType _activeFilter = DateFilterType.allTime;
  DateFilterType get activeFilter => _activeFilter;

  DateTimeRange? _customDateRange;
  DateTimeRange? get customDateRange => _customDateRange;

  Future<void> fetchConsultations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allConsultations = await service.fetchConsultations();
      _allConsultations
          .sort((a, b) => b.header.createDate.compareTo(a.header.createDate));
      _applyFilters();
    } catch (e) {
      _errorMessage = "Failed to load consultations: ${e.toString()}";
      _allConsultations = [];
      _filteredConsultations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  /// --- NEW: Method to set the date filter ---
  void setDateFilter(DateFilterType filter, {DateTimeRange? customRange}) {
    _activeFilter = filter;
    _customDateRange = customRange;
    _applyFilters();
    notifyListeners();
  }

  /// --- UPDATED: Applies BOTH date and search filters ---
  void _applyFilters() {
    List<ConsultationModel> tempConsultations;

    // 1. Apply Date Filter First
    switch (_activeFilter) {
      case DateFilterType.today:
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        tempConsultations = _allConsultations
            .where((c) => c.header.postingDate.isAfter(startOfToday))
            .toList();
        break;
      case DateFilterType.last7Days:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        tempConsultations = _allConsultations
            .where((c) => c.header.postingDate.isAfter(sevenDaysAgo))
            .toList();
        break;
      case DateFilterType.thisMonth:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        tempConsultations = _allConsultations
            .where((c) => c.header.postingDate.isAfter(startOfMonth))
            .toList();
        break;
      case DateFilterType.custom:
        if (_customDateRange != null) {
          final startDate = _customDateRange!.start;
          // Add one day to the end date to include the entire day
          final endDate = _customDateRange!.end.add(const Duration(days: 1));
          tempConsultations = _allConsultations.where((c) {
            return c.header.postingDate.isAfter(startDate) &&
                c.header.postingDate.isBefore(endDate);
          }).toList();
        } else {
          tempConsultations = List.from(_allConsultations);
        }
        break;
      case DateFilterType.allTime:
      default:
        tempConsultations = List.from(_allConsultations);
    }

    // 2. Apply Search Query on the date-filtered list
    if (_searchQuery.isNotEmpty) {
      tempConsultations = tempConsultations.where((consultation) {
        final header = consultation.header;
        return header.petName.toLowerCase().contains(_searchQuery) ||
            header.customerName.toLowerCase().contains(_searchQuery) ||
            header.phone.toLowerCase().contains(_searchQuery) ||
            header.species.toLowerCase().contains(_searchQuery) ||
            header.breed.toLowerCase().contains(_searchQuery) ||
            header.historiesTreatment.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _filteredConsultations = tempConsultations;
  }
}