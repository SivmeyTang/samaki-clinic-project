import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppointmentPage extends StatelessWidget {
  final String? from;

  const AppointmentPage({super.key, this.from});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // If we have a specific route to go back to, use it
            if (from != null && from!.isNotEmpty) {
              context.go(from!);
            }
            // Otherwise, try to pop (which will work for push navigation)
            else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            // Fallback to home if nothing else works
            else {
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
      body: Center(
        child: Container(
          width: 500,
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
              const Text(
                'Schedule Your Appointment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(Icons.person, 'Full Name'),
              _buildDropdown(Icons.tag, 'Select Pet Number'),
              _buildTextField(Icons.phone, 'Phone Number'),
              _buildTextField(Icons.email, 'Email'),
              _buildTextField(Icons.description, 'Reason for Visit',
                  maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildDateField('Select Date')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeField('Select Time')),
                ],
              ),
              _buildDropdown(Icons.pets, 'Select Species'),
              _buildDropdown(Icons.event_note, 'Select Appointment Type'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // handle booking logic
                  },
                  child: const Text(
                    'BOOK APPOINTMENT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildDateField(String hint) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: () {
        // Add date picker logic here
      },
    );
  }

  Widget _buildTimeField(String hint) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.access_time),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: () {
        // Add time picker logic here
      },
    );
  }
}
