import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:samaki_clinic/BackEnd/Service/Pet_Service.dart';


// --- Modern App Theme ---
const Color primaryColor = Color(0xFF6C63FF);
const Color backgroundColor = Color(0xFFF8F9FA);
const Color surfaceColor = Colors.white;
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);
const Color accentColor = Color(0xFF48BB78);

class AddNewPetScreen extends StatefulWidget {
  final int customerId;

  const AddNewPetScreen({super.key, required this.customerId});

  @override
  State<AddNewPetScreen> createState() => _AddNewPetScreenState();
}

class _AddNewPetScreenState extends State<AddNewPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final PetFormData _petFormData = PetFormData();

  @override
  void dispose() {
    // Only dispose the text controller now
    _petFormData.petName.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_petFormData.birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a birth date.'), backgroundColor: Colors.red),
        );
        return;
      }

      final model = _petFormData.toAddPetRequestModel(widget.customerId);
      final provider = context.read<AddPetProvider>();
      final success = await provider.addPet(model);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Pet added successfully!'), backgroundColor: accentColor),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'An unknown error occurred.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Add New Pet', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              PetInfoCard(
                petFormData: _petFormData,
                index: 0,
                onRemove: () {},
              ),
              const SizedBox(height: 24),
              Consumer<AddPetProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryColor)))
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            shadowColor: primaryColor.withOpacity(0.3),
                          ),
                          child: const Text('Save Pet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// == Reusable Widgets and Data Class for the Form                       ==
// =========================================================================

/// A data class to hold the state for a single pet form.
class PetFormData {
  final petName = TextEditingController();
  // CHANGED: These are now nullable strings to hold dropdown values
  String? species = 'Dog';
  String? breed;
  String? gender = 'Male';
  String? color = 'Black';
  String? weight = '5 kg';
  DateTime? birthDate = DateTime.now();
  bool spayedNeutered = false;

  /// Converts the form data into the API request model.
  AddPetRequestModel toAddPetRequestModel(int customerId) {
    // CHANGED: Parse weight from string like "5 kg" to double 5.0
    final weightValue = double.tryParse(RegExp(r'[\d\.]+').firstMatch(weight ?? '')?.group(0) ?? '0.0') ?? 0.0;
    return AddPetRequestModel(
      customerId: customerId,
      petName: petName.text,
      species: species ?? '',
      breed: breed ?? '',
      gender: gender ?? '',
      birthDate: birthDate ?? DateTime.now(),
      spayedNeutered: spayedNeutered,
      weight: weightValue,
      color: color ?? '',
    );
  }
}

/// The reusable card widget for displaying a pet form.
class PetInfoCard extends StatefulWidget {
  final PetFormData petFormData;
  final int index;
  final VoidCallback onRemove;

  const PetInfoCard({
    super.key,
    required this.petFormData,
    required this.index,
    required this.onRemove,
  });

  @override
  State<PetInfoCard> createState() => _PetInfoCardState();
}

class _PetInfoCardState extends State<PetInfoCard> {
  // ADDED: Data lists for the new dropdowns
  final List<String> _petColors = const ['Black', 'White', 'Brown', 'Golden', 'Grey', 'Tabby', 'Spotted', 'Other'];
  final List<String> _petWeights = List.generate(50, (i) => "${i + 1} kg");

  List<String> _getBreedsForSpecies(String? species) {
    switch (species) {
      case 'Dog': return ['Labrador', 'Bulldog', 'Beagle', 'Poodle', 'Other'];
      case 'Cat': return ['Siamese', 'Persian', 'Maine Coon', 'Sphynx', 'Other'];
      case 'Bird': return ['Parrot', 'Canary', 'Cockatiel', 'Finch', 'Other'];
      default: return ['Other'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SectionHeader(
              title: "Pet Details",
              subtitle: "Provide the new pet's information",
              icon: Icons.pets,
            ),
            const SizedBox(height: 24),
            _StyledTextField(
              controller: widget.petFormData.petName,
              label: "Pet Name",
              icon: Icons.pets_outlined,
              validator: (value) => value!.isEmpty ? "Please enter pet name" : null,
            ),
            _StyledDropdown(
              label: "Species",
              value: widget.petFormData.species,
              items: const ['Dog', 'Cat', 'Bird', 'Other'],
              onChanged: (value) => setState(() {
                widget.petFormData.species = value;
                widget.petFormData.breed = null; // Reset breed when species changes
              }),
            ),
            // CHANGED: This is now a dropdown
            _StyledDropdown(
              label: "Breed",
              value: widget.petFormData.breed,
              items: _getBreedsForSpecies(widget.petFormData.species),
              onChanged: (value) => setState(() => widget.petFormData.breed = value),
            ),
            _StyledDropdown(
              label: "Gender",
              value: widget.petFormData.gender,
              items: const ['Male', 'Female'],
              onChanged: (value) => setState(() => widget.petFormData.gender = value),
            ),
            // CHANGED: This is now a dropdown
            _StyledDropdown(
              label: "Color",
              value: widget.petFormData.color,
              items: _petColors,
              onChanged: (value) => setState(() => widget.petFormData.color = value),
            ),
            // CHANGED: This is now a dropdown
            _StyledDropdown(
              label: "Weight",
              value: widget.petFormData.weight,
              items: _petWeights,
              onChanged: (value) => setState(() => widget.petFormData.weight = value),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(text: widget.petFormData.birthDate != null ? DateFormat('MMMM d, y').format(widget.petFormData.birthDate!) : ''),
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: secondaryTextColor.withOpacity(0.7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: widget.petFormData.birthDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: textColor),
                        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryColor)),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() => widget.petFormData.birthDate = picked);
                  }
                },
                validator: (value) => widget.petFormData.birthDate == null ? "Please select birth date" : null,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spayed or Neutered', style: TextStyle(fontSize: 16, color: secondaryTextColor)),
                  Switch(
                    value: widget.petFormData.spayedNeutered,
                    onChanged: (bool value) => setState(() => widget.petFormData.spayedNeutered = value),
                    activeColor: accentColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Reusable Widgets ---

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: secondaryTextColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryTextColor),
          prefixIcon: Icon(icon, color: secondaryTextColor.withOpacity(0.7)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator ?? (value) => value!.isEmpty ? "This field is required" : null,
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        style: const TextStyle(color: textColor, fontFamily: 'Roboto', fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryTextColor),
          prefixIcon: Icon(Icons.arrow_drop_down, color: secondaryTextColor.withOpacity(0.7)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Required" : null,
        icon: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
      ),
    );
  }
}