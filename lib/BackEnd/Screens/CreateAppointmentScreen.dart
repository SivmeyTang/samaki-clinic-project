import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';
import 'package:samaki_clinic/BackEnd/logic/AppointmentProvider.dart';
class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}
class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form field controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _petNumberController = TextEditingController();
  final _detailsController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // State for dropdowns and pickers
  String? _selectedPetNumber; // To match dropdown design
  String? _selectedSpecies;
  String? _appointmentType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _petNumberController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Handles form validation and submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() => _isSaving = true);

    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // =======================================================================
    // === THE FIX IS HERE ===================================================
    // =======================================================================
    // Manually format the time to a standard "HH:mm" string (24-hour format)
    // This ensures the server can always parse it correctly.
    final String formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';


    final newAppointment = Appointment(
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      petOfNumber: _selectedPetNumber!,
      species: _selectedSpecies!,
      appointmentDate: finalDateTime,
      appointmentTime: formattedTime, // <-- USE THE CORRECTLY FORMATTED TIME
      appointmentType: _appointmentType!,
      detail: _detailsController.text.isNotEmpty ? _detailsController.text : null,
    );

    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .createAppointment(newAppointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment Created Successfully! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
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

  // --- UI Helper Methods for picking date and time ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "   ${DateFormat('MMMM dd, yyyy').format(picked)}";
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = "   ${picked.format(context)}";
      });
    }
  }
  
  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue.shade600,
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
                  "Schedule Your Appointment",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 24),

                // --- Form Fields ---
                _buildLabel("Full Name"),
                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputDecoration(hint: "Enter client's full name"),
                  validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel("Pet Number"),
                 DropdownButtonFormField<String>(
                  value: _selectedPetNumber,
                  decoration: _inputDecoration(hint: "Select Pet Number", icon: Icons.tag),
                  items: ['1', '2', '3', '4','5'] // Example list
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPetNumber = v),
                  validator: (v) => v == null ? 'Please select a pet number' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel("Phone Number"),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration(hint: "Enter phone number", icon: Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                   validator: (v) => v!.trim().isEmpty ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                
                _buildLabel("Email (Optional)"),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration(hint: "Enter email address", icon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildLabel("Reason for Visit (Optional)"),
                TextFormField(
                  controller: _detailsController,
                  decoration: _inputDecoration(hint: "Describe the reason for the visit", icon: Icons.notes_outlined),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Side-by-side fields
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Appointment Date"),
                          TextFormField(
                            controller: _dateController,
                            decoration: _inputDecoration(hint: "Select Date", icon: Icons.calendar_today_outlined),
                            readOnly: true,
                            onTap: _pickDate,
                            validator: (v) => v!.isEmpty ? 'Date is required' : null,
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
                            decoration: _inputDecoration(hint: "Select Time", icon: Icons.access_time_outlined),
                            readOnly: true,
                            onTap: _pickTime,
                            validator: (v) => v!.isEmpty ? 'Time is required' : null,
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
                            decoration: _inputDecoration(hint: "Select Species", icon: Icons.pets_outlined),
                            items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedSpecies = v),
                            validator: (v) => v == null ? 'Species is required' : null,
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
                              decoration: _inputDecoration(hint: "Select Type", icon: Icons.category_outlined),
                              items: ['Check-up', 'Vaccination', 'Surgery', 'Emergency', 'Consultation']
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) => setState(() => _appointmentType = v),
                              validator: (v) => v == null ? 'Type is required' : null,
                            ),
                        ],
                      ),
                    ),
                  ],
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

  // --- Helper Widgets for consistent styling ---

  /// Builds the label text that appears above each form field.
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

  /// Creates a consistent InputDecoration for all form fields.
  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
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
        borderSide: BorderSide(color: Colors.blue.shade500, width: 1.5),
      ),
    );
  }

  /// Builds the main submission button.
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue.shade600,
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
                'BOOK APPOINTMENT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}