import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:samaki_clinic/BackEnd/Model/Appointment_model.dart';
import 'package:samaki_clinic/BackEnd/Service/Appointment_service.dart';
import 'package:samaki_clinic/BackEnd/logic/AppointmentProvider.dart';


class AppointmentPage extends StatefulWidget {
  final String? from;

  const AppointmentPage({super.key, this.from});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedPetNumber;
  String? _selectedSpecies;
  String? _selectedAppointmentType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Example data for dropdowns
  final List<String> _petNumbers = ['1', '2', ' 3',' 4',' 5',' 6'];
  final List<String> _species = ['Dog', 'Cat', 'Bird', 'Rabbit'];
  final List<String> _appointmentTypes = ['Vaccination', 'Check-up', 'Surgery', 'Grooming'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.from != null && widget.from!.isNotEmpty) {
              context.go(widget.from!);
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
              width: isMobile ? screenSize.width * 0.9 : isTablet ? 500 : 600,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Schedule Your Appointment',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context,
                    _fullNameController,
                    Icons.person,
                    'Full Name',
                    isMobile: isMobile,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context,
                    Icons.tag,
                    'Select Pet Number',
                    _petNumbers,
                    _selectedPetNumber,
                    (value) => setState(() => _selectedPetNumber = value),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    _phoneNumberController,
                    Icons.phone,
                    'Phone Number',
                    isMobile: isMobile,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    _emailController,
                    Icons.email,
                    'Email (Optional)',
                    isMobile: isMobile,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    _reasonController,
                    Icons.description,
                    'Reason for Visit (Optional)',
                    maxLines: 3,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(context, 'Select Date', isMobile: isMobile),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeField(context, 'Select Time', isMobile: isMobile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context,
                    Icons.pets,
                    'Select Species',
                    _species,
                    _selectedSpecies,
                    (value) => setState(() => _selectedSpecies = value),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context,
                    Icons.event_note,
                    'Select Appointment Type',
                    _appointmentTypes,
                    _selectedAppointmentType,
                    (value) => setState(() => _selectedAppointmentType = value),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 50 : 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final provider = Provider.of<AppointmentProvider>(context, listen: false);
                            final newAppointment = Appointment(
                              fullName: _fullNameController.text,
                              phoneNumber: _phoneNumberController.text,
                              petOfNumber: _selectedPetNumber!,
                              species: _selectedSpecies!,
                              appointmentDate: _selectedDate!,
                              appointmentType: _selectedAppointmentType!,
                              appointmentTime: _selectedTime!.format(context),
                              email: _emailController.text.isNotEmpty ? _emailController.text : null,
                              detail: _reasonController.text.isNotEmpty ? _reasonController.text : null,
                            );

                            await provider.createAppointment(newAppointment);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Appointment booked successfully!')),
                              );
                              context.go('/');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        'BOOK APPOINTMENT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    IconData icon,
    String hint, {
    int maxLines = 1,
    required bool isMobile,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    IconData icon,
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged, {
    required bool isMobile,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String hint, {
    required bool isMobile,
  }) {
    return TextFormField(
      controller: TextEditingController(
        text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      ),
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 1),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      validator: (value) => _selectedDate == null ? 'Please select a date' : null,
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String hint, {
    required bool isMobile,
  }) {
    return TextFormField(
      controller: TextEditingController(
        text: _selectedTime != null ? _selectedTime!.format(context) : '',
      ),
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.access_time),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      validator: (value) => _selectedTime == null ? 'Please select a time' : null,
    );
  }
}