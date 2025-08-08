import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';
import 'package:samaki_clinic/BackEnd/logic/AppointmentProvider.dart';


class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment; // Pass the appointment to be edited

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() =>
      _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form field controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _detailsController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  // State variables
  late String _selectedPetNumber;
  late String _selectedSpecies;
  late String _appointmentType;
  late String _selectedStatus;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final appointment = widget.appointment;

    // Initialize controllers
    _fullNameController = TextEditingController(text: appointment.fullName);
    _phoneController = TextEditingController(text: appointment.phoneNumber);
    _emailController = TextEditingController(text: appointment.email);
    _detailsController = TextEditingController(text: appointment.detail);

    // Initialize state variables
    _selectedPetNumber = appointment.petOfNumber;
    _selectedSpecies = appointment.species;
    _appointmentType = appointment.appointmentType;
    _selectedDate = appointment.appointmentDate;
    _selectedTime = TimeOfDay.fromDateTime(appointment.appointmentDate);
    _selectedStatus = (appointment.status?.isNotEmpty ?? false) ? appointment.status! : 'Pending';

    _dateController = TextEditingController();
    _timeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set display text using the now-safe context
    _dateController.text = "   ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}";
    _timeController.text = "   ${_selectedTime.format(context)}";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    // Only the status validator is truly needed, but we keep the form structure
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    
    // We only need to send the ID and the new status.
    // However, since the service/model expects a full object,
    // we send back the original data for all other fields.
    final updatedAppointment = Appointment(
      appointmentId: widget.appointment.appointmentId,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      petOfNumber: _selectedPetNumber,
      species: _selectedSpecies,
      appointmentDate: _selectedDate,
      appointmentTime: widget.appointment.appointmentTime, // Keep original
      appointmentType: _appointmentType,
      detail: _detailsController.text.isNotEmpty ? _detailsController.text : null,
      status: _selectedStatus, // The only changed value
      createdDate: widget.appointment.createdDate,
    );

    try {
      // NOTE: You could use the specialized `updateAppointmentStatus` provider method here
      // for a cleaner API call, but the full update also works.
      await Provider.of<AppointmentProvider>(context, listen: false)
          .updateAppointment(updatedAppointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status Updated Successfully! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving status: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // A specific decoration for disabled fields to make them look read-only
    InputDecoration disabledInputDecoration({required String hint, IconData? icon}) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        filled: true,
        fillColor: Colors.grey[200], // Grey background to indicate it's disabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300), // No highlight on focus
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Change Appointment Status',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Appointment Details",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "All fields are read-only except for the status.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                
                _buildLabel("Full Name"),
                TextFormField(
                  controller: _fullNameController,
                  readOnly: true, // --- MAKE READ-ONLY ---
                  decoration: disabledInputDecoration(hint: "Client's full name"),
                ),
                const SizedBox(height: 16),
                
                _buildLabel("Pet Number"),
                DropdownButtonFormField<String>(
                  value: _selectedPetNumber,
                  decoration: disabledInputDecoration(hint: "Pet Number", icon: Icons.tag),
                  items: [_selectedPetNumber] // Only show the current value
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: null, // --- DISABLE ONCHANGED ---
                ),
                const SizedBox(height: 16),
                
                _buildLabel("Phone Number"),
                TextFormField(
                  controller: _phoneController,
                  readOnly: true, // --- MAKE READ-ONLY ---
                  decoration: disabledInputDecoration(hint: "Phone number", icon: Icons.phone_outlined),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Appointment Date"),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true, // --- MAKE READ-ONLY ---
                            decoration: disabledInputDecoration(hint: "Select Date", icon: Icons.calendar_today_outlined),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Appointment Time"),
                          TextFormField(
                            controller: _timeController,
                            readOnly: true, // --- MAKE READ-ONLY ---
                            decoration: disabledInputDecoration(hint: "Select Time", icon: Icons.access_time_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Species"),
                          DropdownButtonFormField<String>(
                            value: _selectedSpecies,
                            decoration: disabledInputDecoration(hint: "Species", icon: Icons.pets_outlined),
                            items: [_selectedSpecies]
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: null, // --- DISABLE ONCHANGED ---
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Appointment Type"),
                          DropdownButtonFormField<String>(
                            value: _appointmentType,
                            decoration: disabledInputDecoration(hint: "Type", icon: Icons.category_outlined),
                            items: [_appointmentType]
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: null, // --- DISABLE ONCHANGED ---
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // --- THIS IS THE ONLY EDITABLE FIELD ---
                _buildLabel("Status (Editable)"),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: _inputDecoration(hint: "Select Status", icon: Icons.flag_outlined),
                  items: ['Pending', 'Completed', 'Cancelled'] // Added Cancelled as an option
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                     if (value != null) setState(() => _selectedStatus = value);
                  },
                  validator: (value) => value == null ? 'Status is required' : null,
                ),
                const SizedBox(height: 32),
                
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    // This is the decoration for the editable status dropdown
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 1.5),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepPurple.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white),
              )
            : const Text(
                'SAVE STATUS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}