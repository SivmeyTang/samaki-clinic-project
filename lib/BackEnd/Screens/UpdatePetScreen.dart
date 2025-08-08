// lib/Screen.dart/update_pet_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';
import 'package:samaki_clinic/BackEnd/Service/Pet_Service.dart';
 // Re-use PetModel

class UpdatePetScreen extends StatefulWidget {
  final PetModel pet; // Pass the existing pet data to the screen

  const UpdatePetScreen({super.key, required this.pet});

  @override
  State<UpdatePetScreen> createState() => _UpdatePetScreenState();
}

class _UpdatePetScreenState extends State<UpdatePetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _petNameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _weightController;
  late TextEditingController _birthDateController;
  String? _gender;
  bool _isSpayedNeutered = false;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill the controllers with the existing pet's data
    final pet = widget.pet;
    _petNameController = TextEditingController(text: pet.petName);
    _speciesController = TextEditingController(text: pet.species);
    _breedController = TextEditingController(text: pet.breed);
    _colorController = TextEditingController(text: pet.color);
    _weightController = TextEditingController(text: pet.weight.toString());
    _selectedBirthDate = pet.birthDate;
    _birthDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(pet.birthDate),
    );
    _gender = pet.gender;
    _isSpayedNeutered = pet.spayedNeutered;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AddPetProvider>();

      final model = UpdatePetRequestModel(
        petId: widget.pet.petId, // Crucial for update
        customerId: widget.pet.customerId,
        petName: _petNameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        gender: _gender!,
        color: _colorController.text,
        birthDate: _selectedBirthDate!,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        spayedNeutered: _isSpayedNeutered,
      );

      final success = await provider.updatePet(model);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update pet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pet Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_petNameController, 'Pet Name'),
              const SizedBox(height: 16),
              _buildTextField(_speciesController, 'Species (e.g., Dog, Cat)'),
              const SizedBox(height: 16),
              _buildTextField(_breedController, 'Breed'),
              const SizedBox(height: 16),
              _buildTextField(_colorController, 'Color'),
              const SizedBox(height: 16),
              _buildTextField(_weightController, 'Weight (kg)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              _buildSpayedNeuteredSwitch(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: context.watch<AddPetProvider>().isLoading
                    ? null
                    : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: context.watch<AddPetProvider>().isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? 'This field cannot be empty' : null,
    );
  }

  TextFormField _buildDateField() {
    return TextFormField(
      controller: _birthDateController,
      decoration: InputDecoration(
        labelText: 'Birth Date',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) =>
          _selectedBirthDate == null ? 'Please select a birth date' : null,
    );
  }

  DropdownButtonFormField<String> _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: ['Male', 'Female']
          .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }

  SwitchListTile _buildSpayedNeuteredSwitch() {
    return SwitchListTile(
      title: const Text('Spayed or Neutered'),
      value: _isSpayedNeutered,
      onChanged: (bool value) {
        setState(() {
          _isSpayedNeutered = value;
        });
      },
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }
}