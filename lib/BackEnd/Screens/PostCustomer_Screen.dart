import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Screens/daskboard_Screen.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';
import '../Model/customer_add_model.dart';
import '../logic/customer_add_provider.dart';

// --- App Theme ---
const Color primaryColor = Color(0xFF6C63FF);
const Color primaryVariantColor = Color(0xFF4A42CC);
const Color backgroundColor = Color(0xFFF8F9FA);
const Color surfaceColor = Colors.white;
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);
const Color accentColor = Color(0xFF48BB78);

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({super.key});

  @override
  State<AddNewCustomerScreen> createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _petListKey = GlobalKey<AnimatedListState>();

  // --- Data for Dropdowns ---
  final List<String> _provinces = const [
    'Phnom Penh', 'Banteay Meanchey', 'Battambang', 'Kampong Cham',
    'Kampong Chhnang', 'Kampong Speu', 'Kampong Thom', 'Kampot', 'Kandal',
    'Kep', 'Koh Kong', 'Kratié', 'Mondulkiri', 'Oddar Meanchey', 'Pailin',
    'Preah Sihanouk', 'Preah Vihear', 'Prey Veng', 'Pursat', 'Ratanakiri',
    'Siem Reap', 'Stung Treng', 'Svay Rieng', 'Takéo', 'Tboung Khmum'
  ];
  final List<String> _petColors = const ['Black', 'White', 'Brown', 'Golden', 'Grey', 'Tabby', 'Spotted', 'Other'];
  final List<String> _petWeights = List.generate(50, (i) => "${i + 1} kg");

  // --- Controllers & State Variables ---
  final _fullNameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController(text: "Mr.");
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedProvince = 'Phnom Penh';

  int _currentPage = 0;
  final List<PetFormData> petForms = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty pet form
    petForms.add(PetFormData());
  }

  void _addPetForm() {
    final newIndex = petForms.length;
    petForms.add(PetFormData());
    _petListKey.currentState?.insertItem(newIndex, duration: const Duration(milliseconds: 300));
  }

  void _removePetForm(int index) {
    if (index < 0 || index >= petForms.length || petForms.length <= 1) return;

    final petData = petForms[index];
    petForms.removeAt(index);
    _petListKey.currentState?.removeItem(
      index,
      (context, animation) => PetInfoCard.buildAnimated(
        context: context,
        petFormData: petData,
        index: index,
        animation: animation,
        onRemove: () {}, // No action needed here
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submit() async {
   // 1. Validate all forms on both pages
   if (!_formKey.currentState!.validate()) {
    // If validation fails, jump back to the first page to show the error
    if (_currentPage != 0) {
      _pageController.jumpToPage(0);
    }
    return;
   }
   if (petForms.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please add at least one pet."),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  // 2. Construct the data model
  final header = CustomerHeader(
    customerId: 0, 
    fullName: _fullNameCtrl.text,
    title: _titleCtrl.text,
    email: _emailCtrl.text,
    phone: _phoneCtrl.text,
    address: _selectedProvince ?? '',
    createDate: DateTime.now(),
  );

  final pets = petForms.map((p) => p.toPetDetail()).toList();
  final model = CustomerRequestModel(header: header, detail: pets);
  
  // 3. Call the provider to save the data
  final provider = context.read<CustomerAddProvider>();
  final success = await provider.addCustomer(model);

  if (!mounted) return;

  // 4. Handle the result
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 Customer saved successfully!"),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Refresh the customer list so the new entry appears
    await Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();

    // Navigate back to the Dashboard and show the Customer List page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const DashboardPage(initialIndex: 4), // 4 is the index for Customer List
      ),
      (route) => false, // This removes all previous screens
    );

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Failed to save customer. Please try again."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _currentPage == 0 ? "Customer Information" : "Pet Details",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          onPageChanged: _onPageChanged,
          children: [
            _buildCustomerInfoPage(),
            _buildPetInfoPage(),
          ],
        ),
      ),
      floatingActionButton: _currentPage == 1 ? FloatingActionButton(
        onPressed: _addPetForm,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCustomerInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: "Client Details",
            subtitle: "Please provide the owner's information",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _StyledTextField(
            controller: _fullNameCtrl,
            label: "Full Name",
            icon: Icons.person_outline,
            validator: (value) => value!.isEmpty ? "Please enter full name" : null,
          ),
          _StyledTextField(
            controller: _titleCtrl,
            label: "Title (e.g., Mr., Mrs.)",
            icon: Icons.badge_outlined,
            validator: (value) => value!.isEmpty ? "Please enter title" : null,
          ),
          _StyledTextField(
            controller: _emailCtrl,
            label: "Email Address",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty 
              ? "Please enter email" 
              : !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
                ? "Enter a valid email"
                : null,
          ),
          _StyledTextField(
            controller: _phoneCtrl,
            label: "Phone Number",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
              ? "Please enter phone number" 
              : value.length < 8 
                ? "Phone number too short"
                : null,
          ),
          _StyledDropdown(
            label: "Province / City",
            value: _selectedProvince,
            items: _provinces,
            onChanged: (value) => setState(() => _selectedProvince = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: _SectionHeader(
            title: "Registered Pets",
            subtitle: "Add one or more pets for this client",
            icon: Icons.pets,
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _petListKey,
            initialItemCount: petForms.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index, animation) {
              return PetInfoCard.buildAnimated(
                context: context,
                petFormData: petForms[index],
                index: index,
                animation: animation,
                onRemove: () => _removePetForm(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    final provider = context.watch<CustomerAddProvider>(); 
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: provider.isLoading
      ? const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        )
      : Row(
          children: [
            if (_currentPage == 1)
              OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: primaryColor),
                ),
                child: const Text(
                  "BACK",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              onPressed: _currentPage == 0 ? _nextPage : _submit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPage == 0 ? 'CONTINUE' : 'SAVE CUSTOMER',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == 0 ? Icons.arrow_forward : Icons.check,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
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
          child: Icon(
            icon,
            size: 24,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
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
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: secondaryTextColor),
          prefixIcon: Icon(Icons.arrow_drop_down, color: secondaryTextColor.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: textColor)),
        )).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "This field is required" : null,
        icon: const Icon(Icons.arrow_drop_down, color: secondaryTextColor),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
      ),
    );
  }
}

class PetInfoCard extends StatefulWidget {
  final PetFormData petFormData;
  final int index;
  final VoidCallback onRemove;
  final Animation<double> animation;

  const PetInfoCard({
    super.key,
    required this.petFormData,
    required this.index,
    required this.onRemove,
    required this.animation,
  });
  
  static Widget buildAnimated({
    required BuildContext context,
    required PetFormData petFormData,
    required int index,
    required Animation<double> animation,
    required VoidCallback onRemove,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
        child: PetInfoCard(
          petFormData: petFormData,
          index: index,
          animation: animation,
          onRemove: onRemove,
        ),
      ),
    );
  }
  
  @override
  State<PetInfoCard> createState() => _PetInfoCardState();
}

class _PetInfoCardState extends State<PetInfoCard> {
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
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pet #${widget.index + 1}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                if (widget.index > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: widget.onRemove,
                    splashRadius: 20,
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
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
            _StyledDropdown(
              label: "Color",
              value: widget.petFormData.color,
              items: _petColors,
              onChanged: (value) => setState(() => widget.petFormData.color = value),
            ),
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
                controller: TextEditingController(
                  text: widget.petFormData.birthDate?.toLocal().toString().split(' ')[0] ?? '',
                ),
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  labelStyle: const TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: secondaryTextColor.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 1.5),
                  ),
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
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryColor,
                            onPrimary: Colors.white,
                            onSurface: textColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => widget.petFormData.birthDate = picked);
                  }
                },
                validator: (value) => widget.petFormData.birthDate == null ? "Please select birth date" : null,
              ),
            ),
            CheckboxListTile(
              title: const Text(
                "Spayed / Neutered",
                style: TextStyle(color: textColor),
              ),
              value: widget.petFormData.spayedNeutered,
              onChanged: (value) => setState(() => widget.petFormData.spayedNeutered = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: primaryColor,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              tileColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class PetFormData {
  final petName = TextEditingController();
  String? species = 'Dog';
  String? breed;
  String? gender = 'Male';
  DateTime? birthDate = DateTime.now();
  bool spayedNeutered = false;
  String? color = 'Black';
  String? weight = '5 kg';

  PetDetail toPetDetail() {
    final weightValue = double.tryParse(RegExp(r'[\d\.]+').firstMatch(weight ?? '')?.group(0) ?? '0.0') ?? 0.0;
    return PetDetail(
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