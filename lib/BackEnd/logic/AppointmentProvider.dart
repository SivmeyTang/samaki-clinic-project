import 'package:flutter/material.dart';
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';
import 'package:samaki_clinic/BackEnd/Service/Appointment_service.dart';


class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _allAppointments = []; // Holds the original, unfiltered list
  List<Appointment> _appointments = [];    // Holds the list to be displayed (filtered)
  bool _isLoading = false;
  String? _error;
  String _searchQuery = ''; // To keep track of the current search term

  // Public getters
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AppointmentService _appointmentService = AppointmentService();

  /// Fetches all appointments from the service.
  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAppointments = await _appointmentService.getAllAppointments();

      // --- IMPROVEMENT: SORT THE LIST HERE ---
      // This sorts the list so the newest appointments (by createdDate) are always on top.
      _allAppointments.sort((a, b) {
        // Handle cases where dates might be null
        if (a.createdDate == null) return 1;
        if (b.createdDate == null) return -1;
        return b.createdDate!.compareTo(a.createdDate!);
      });
      // --- END OF IMPROVEMENT ---

      // This will now operate on the sorted list
      searchAppointments(_searchQuery);
      
    } catch (e) {
      _error = e.toString();
      _allAppointments = [];
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new appointment and then refreshes the list.
  Future<void> createAppointment(Appointment newAppointment) async {
    try {
      await _appointmentService.postAppointment(newAppointment);
      await fetchAppointments(); // This will fetch and sort the new list
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // --- NEW METHOD ---
  /// Updates an existing appointment and then refreshes the list.
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _appointmentService.updateAppointment(appointment);
      await fetchAppointments(); // Refresh the list to show the updated data
    } catch (e) {
      // Re-throw the clean error message from the service
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
  // --- END OF NEW METHOD ---

  /// Filters the list of appointments based on a search query.
  void searchAppointments(String query) {
    _searchQuery = query;

    if (_searchQuery.isEmpty) {
      _appointments = List<Appointment>.from(_allAppointments);
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _appointments = _allAppointments.where((appointment) {
        final clientName = appointment.fullName?.toLowerCase() ?? '';
        final appointmentId = appointment.appointmentId?.toString() ?? '';
        final phoneNumber = appointment.phoneNumber?.toLowerCase() ?? '';
        final email = appointment.email?.toLowerCase() ?? '';
        final status = appointment.status?.toLowerCase() ?? '';

        return clientName.contains(queryLower) ||
            appointmentId.contains(queryLower) ||
            phoneNumber.contains(queryLower) ||
            email.contains(queryLower) ||
            status.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }
}