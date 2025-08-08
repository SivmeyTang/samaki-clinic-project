// AddConsultationScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Screens/CustomerList_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/daskboard_Screen.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';
import 'package:samaki_clinic/BackEnd/logic/consultation_provider.dart';

import '../Model/ConsultationModel.dart';
import '../Model/CustomerList_Model.dart';

class AddConsultationScreen extends StatefulWidget {
  const AddConsultationScreen(
      {Key? key, this.selectedCustomer, this.selectedPets})
      : super(key: key);

  final CustomerModel? selectedCustomer;
  final List<PetModel>? selectedPets;

  @override
  State<AddConsultationScreen> createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _historiesController = TextEditingController();

  DateTime _postingDate = DateTime.now();

  final List<Map<String, dynamic>> _addedImmunizations = [];

  // --- MODIFIED: State for the dropdown ---
  final List<String> _immunizationOptions = const [ // <-- ADDED: List of dropdown options
    'Check-up',
    'Vaccination',
    'Surgery',
    'Emergency',
    'Consultation',
  ];
  String? _selectedImmunizationType; // <-- ADDED: Holds the selected value
  // --- END MODIFICATION ---

  DateTime _givenDate = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 30));
  DateTime _notifyDate = DateTime.now().add(const Duration(days: 25));

  bool _isSubmitting = false;
  int? _selectedCustomerId;
  List<PetModel> _selectedPets = [];
  List<PetModel> _customerPets = [];
  bool _isLoadingPets = false;

  PetModel? _displayPetData;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCustomer != null) {
      _selectedCustomerId = widget.selectedCustomer!.customerId;
      _customerNameController.text = widget.selectedCustomer!.fullName;
      _phoneController.text = widget.selectedCustomer!.phone;
      _loadCustomerPets(widget.selectedCustomer!.customerId);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _historiesController.dispose();
    // _immunizationTypeController.dispose(); // <-- MODIFIED: Controller removed
    super.dispose();
  }

  Future<void> _loadCustomerPets(int customerId) async {
    setState(() => _isLoadingPets = true);
    try {
      final provider = Provider.of<CustomerProvider>(context, listen: false);
      final customerWithPets = await provider.getCustomerWithPets(customerId);
      if (customerWithPets != null && mounted) {
        setState(() => _customerPets = customerWithPets.detail);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPets = false);
    }
  }

  void _togglePetSelection(PetModel pet) {
    setState(() {
      if (_selectedPets.contains(pet)) {
        _selectedPets.clear();
        _displayPetData = null;
      } else {
        _selectedPets.clear();
        _selectedPets.add(pet);
        _displayPetData = pet;
      }
    });
  }

  Future<void> _selectCustomer() async {
    final selectedCustomer = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(builder: (context) => const CustomerListViewScreen()),
    );
    if (selectedCustomer != null && mounted) {
      setState(() {
        _selectedCustomerId = selectedCustomer.customerId;
        _customerNameController.text = selectedCustomer.fullName;
        _phoneController.text = selectedCustomer.phone;
        _selectedPets.clear();
        _customerPets.clear();
        _displayPetData = null;
      });
      _loadCustomerPets(selectedCustomer.customerId);
    }
  }

  Future<void> _selectDate(
      DateTime currentDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != currentDate) {
      onDateSelected(picked);
    }
  }

  // --- MODIFIED: Logic updated to use the dropdown's selected value ---
  void _addCurrentImmunizationToList() {
    if (_selectedImmunizationType != null) { // <-- MODIFIED: Check the new variable
      setState(() {
        _addedImmunizations.add({
          'immunizationType': _selectedImmunizationType!, // <-- MODIFIED: Use the variable
          'givenDate': _givenDate,
          'nextDueDate': _nextDueDate,
          'notifyDate': _notifyDate,
        });
        _selectedImmunizationType = null; // <-- MODIFIED: Reset the dropdown
        _givenDate = DateTime.now();
        _nextDueDate = DateTime.now().add(const Duration(days: 30));
        _notifyDate = DateTime.now().add(const Duration(days: 25));
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an immunization type to add.')), // <-- MODIFIED: Message updated
      );
    }
  }
  // --- END MODIFICATION ---

  void _removeImmunization(int index) {
    setState(() {
      _addedImmunizations.removeAt(index);
    });
  }

  // --- MODIFIED: Logic updated to use the dropdown's selected value ---
  Future<void> _submitConsultation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please correct the errors before saving.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet.')),
      );
      setState(() {
        _currentStep = 0; // Go back to the first step
      });
      return;
    }

    setState(() => _isSubmitting = true);

    final List<Map<String, dynamic>> allImmunizationsToSave =
        List.from(_addedImmunizations);

    // --- MODIFIED: Also check the dropdown value before saving ---
    if (_selectedImmunizationType != null) { // <-- MODIFIED
      allImmunizationsToSave.add({
        'immunizationType': _selectedImmunizationType!, // <-- MODIFIED
        'givenDate': _givenDate,
        'nextDueDate': _nextDueDate,
        'notifyDate': _notifyDate,
      });
    }
    // --- END MODIFICATION ---

    try {
      final provider = Provider.of<ConsultationProvider>(context, listen: false);
      final pet = _selectedPets.first;

      final header = ConsultationHeader(
          consultId: 0,
          customerId: _selectedCustomerId ?? 0,
          customerName: _customerNameController.text,
          phone: _phoneController.text,
          petName: pet.petName,
          species: pet.species,
          breed: pet.breed,
          gender: pet.gender,
          postingDate: _postingDate,
          historiesTreatment: _historiesController.text,
          createDate: DateTime.now(),
          petId: pet.petId);

      final details = allImmunizationsToSave
          .map((immun) => ImmunizationDetail(
                immunId: 0,
                consultId: 0,
                immunizationType: immun['immunizationType'],
                givenDate: immun['givenDate'],
                nextDueDate: immun['nextDueDate'],
                notifyDate: immun['notifyDate'],
              ))
          .toList();

      final consultation = ConsultationModel(header: header, detail: details);
      final result = await provider.service.saveConsultation(consultation);

      if (mounted) {
        if (result != null && result['success'] == true) {
          await provider.fetchConsultations();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(initialIndex: 2),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result?['message'] ?? 'Failed to save.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Consultation Record'),
      ),
      body: Form(
        key: _formKey,
        child: _isSubmitting
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving...'),
                ],
              ))
            : Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                onStepContinue: () {
                  final isLastStep = _currentStep == getSteps().length - 1;
                  if (isLastStep) {
                    _submitConsultation();
                  } else {
                    setState(() => _currentStep += 1);
                  }
                },
                onStepCancel: _currentStep == 0
                    ? null
                    : () => setState(() => _currentStep -= 1),
                steps: getSteps(),
                controlsBuilder: (context, details) {
                  final isLastStep = _currentStep == getSteps().length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep != 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastStep
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(isLastStep
                              ? Icons.save_alt_outlined
                              : Icons.arrow_forward),
                          label: Text(isLastStep ? 'Save' : 'Continue'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  List<Step> getSteps() => [
        Step(
          title: const Text('Owner & Patient'),
          subtitle: const Text('Select the customer and their pet'),
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 0,
          content: _buildStep1Content(),
        ),
        Step(
          title: const Text('Medical Details'),
          subtitle: const Text('Add treatment notes and date'),
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 1,
          content: _buildStep2Content(),
        ),
        Step(
          title: const Text('Immunization Records'),
          subtitle: const Text('Log vaccinations and schedule'),
          isActive: _currentStep >= 2,
          content: _buildStep3Content(),
        ),
      ];

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Details',
                style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              onPressed: _selectCustomer,
              label: const Text('Select Customer'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _customerNameController,
          decoration: const InputDecoration(
              labelText: 'Name',
              icon: Icon(Icons.person_outline),
              border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Please select a customer' : null,
          readOnly: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
              labelText: 'Phone',
              icon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Phone number required' : null,
          readOnly: true,
        ),
        const Divider(height: 24),
        Text('Select Patient', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_isLoadingPets) const Center(child: CircularProgressIndicator()),
        if (!_isLoadingPets &&
            _customerPets.isEmpty &&
            _selectedCustomerId != null)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('This customer has no registered pets. 🐾'),
          )),
        if (!_isLoadingPets && _customerPets.isNotEmpty)
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: _customerPets.map((pet) {
              final isSelected = _selectedPets.contains(pet);
              return ChoiceChip(
                label: Text(pet.petName),
                avatar: Icon(Icons.pets,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor),
                selected: isSelected,
                onSelected: (_) => _togglePetSelection(pet),
                selectedColor: Theme.of(context).primaryColor,
                labelStyle:
                    TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
        if (_displayPetData != null) const Divider(height: 24),
        if (_displayPetData != null) _buildSelectedPetData(_displayPetData!),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _historiesController,
          decoration: const InputDecoration(
            labelText: 'Treatment Notes & History',
            hintText: 'Enter all relevant medical notes here...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          maxLines: 7,
          validator: (v) =>
              v!.isEmpty ? 'Medical notes cannot be empty' : null,
        ),
        const SizedBox(height: 16),
        _buildDateField('Posting Date', _postingDate, (newDate) {
          setState(() => _postingDate = newDate);
        }),
      ],
    );
  }

  // --- MODIFIED: Replaced TextFormField with DropdownButtonFormField ---
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_addedImmunizations.isNotEmpty) _buildImmunizationList(),
        if (_addedImmunizations.isNotEmpty) const Divider(height: 16),
        Text('Add New Record',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        // --- THIS IS THE KEY CHANGE ---
        DropdownButtonFormField<String>(
          value: _selectedImmunizationType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Immunization / Vaccine Type',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          hint: const Text('Select a type...'),
          items: _immunizationOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedImmunizationType = newValue;
            });
          },
          // You can add a validator if it's a required field
          // validator: (value) => value == null ? 'Please select a type' : null,
        ),
        // --- END OF THE KEY CHANGE ---
        const SizedBox(height: 12),
        _buildDateField('Given Date', _givenDate, (newDate) {
          setState(() => _givenDate = newDate);
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField('Next Due', _nextDueDate, (newDate) {
                setState(() => _nextDueDate = newDate);
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField('Notify', _notifyDate, (newDate) {
                setState(() => _notifyDate = newDate);
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add This Immunization to List'),
            onPressed: _addCurrentImmunizationToList,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
  // --- END MODIFICATION ---

  Widget _buildSelectedPetData(PetModel pet) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          _buildPetDetailRow('Name:', pet.petName),
          _buildPetDetailRow('Species:', pet.species),
          _buildPetDetailRow('Breed:', pet.breed),
          _buildPetDetailRow('Gender:', pet.gender),
        ],
      ),
    );
  }

  Widget _buildPetDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(children: [
        SizedBox(
            width: 65,
            child:
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text(value)),
      ]),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () => _selectDate(date, onDateSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(date)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImmunizationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Added Records', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _addedImmunizations.length,
          itemBuilder: (context, index) {
            final immun = _addedImmunizations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              elevation: 0,
              color: Colors.blue.withOpacity(0.05),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(immun['immunizationType'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Next Due: ${DateFormat('dd MMM yyyy').format(immun['nextDueDate'])}'),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Remove this record',
                  onPressed: () => _removeImmunization(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}