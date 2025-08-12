import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';
import 'package:samaki_clinic/BackEnd/Screens/New_pets_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/PostConsultationScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/UpdateCustomerScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/UpdatePetScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/PostCustomer_Screen.dart';
import 'package:samaki_clinic/BackEnd/Service/Pet_Service.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerUpdateProvider.dart';
import 'package:samaki_clinic/BackEnd/logic/customer_add_provider.dart';


// --- Constants remain the same ---
const Color primaryColor = Color(0xFF2196F3);
const Color primaryColorDark = Color(0xFF1976D2);
const Color accentColor = Color(0xFF4CAF50);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color cardColor = Colors.white;
const Color textColorPrimary = Color(0xFF212121);
const Color textColorSecondary = Color(0xFF757575);
const double defaultPadding = 8.0;
const double smallPadding = 4.0;
const double borderRadius = 8.0;

class CustomerListViewScreen extends StatefulWidget {
  // NEW: Add a flag to determine the mode of the screen.
  final bool isSelectionMode;
  
  const CustomerListViewScreen({super.key, this.isSelectionMode = false});

  @override
  State<CustomerListViewScreen> createState() => _CustomerListViewScreenState();
}

class _CustomerListViewScreenState extends State<CustomerListViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isSearching = false;
  bool _showFilters = false;

  CustomerWithPets? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await context.read<CustomerProvider>().fetchCustomers();
      if (mounted && (MediaQuery.of(context).size.width > 900)) {
        final provider = context.read<CustomerProvider>();
        if (provider.filteredCustomers.isNotEmpty) {
          setState(() {
            _selectedCustomer = provider.filteredCustomers.first;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  // Navigation methods remain the same...
  Future<T?> _navigateTo<T>(Widget page) async {
    return await Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _handleNavigationResult<T>(Future<T?> navigationFuture, Function(T?) onResult) async {
    final result = await navigationFuture;
    if (mounted && result != null) {
      onResult(result);
    }
  }

  Future<void> _navigateToAddCustomer() async {
    await _handleNavigationResult<bool>(
      _navigateTo(
        ChangeNotifierProvider(
          create: (_) => CustomerAddProvider(),
          child: const AddNewCustomerScreen(),
        ),
      ),
      (customerAdded) {
        if (customerAdded == true) {
          context.read<CustomerProvider>().fetchCustomers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully')),
          );
        }
      },
    );
  }

  Future<void> _navigateToAddPet(int customerId) async {
    await _handleNavigationResult<bool>(
      _navigateTo(
        ChangeNotifierProvider(
          create: (_) => AddPetProvider(),
          child: AddNewPetScreen(customerId: customerId),
        ),
      ),
      (petAdded) {
        if (petAdded == true) {
          context.read<CustomerProvider>().fetchCustomers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet added successfully')),
          );
        }
      },
    );
  }

  Future<void> _navigateToUpdatePet(PetModel pet) async {
    await _handleNavigationResult<bool>(
      _navigateTo(
        ChangeNotifierProvider(
          create: (_) => AddPetProvider(),
          child: UpdatePetScreen(pet: pet),
        ),
      ),
      (petUpdated) {
        if (petUpdated == true) {
          context.read<CustomerProvider>().fetchCustomers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet updated successfully')),
          );
        }
      },
    );
  }

  Future<void> _navigateToUpdateCustomer(CustomerModel customer) async {
    await _handleNavigationResult<bool>(
      _navigateTo(
        ChangeNotifierProvider(
          create: (_) => CustomerUpdateProvider(),
          child: UpdateCustomerScreen(customer: customer),
        ),
      ),
      (customerUpdated) {
        if (customerUpdated == true) {
          context.read<CustomerProvider>().fetchCustomers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer updated successfully')),
          );
        }
      },
    );
  }

  Future<void> _navigateToConsultation(CustomerWithPets customerWithPets) async {
    await _navigateTo(
      AddConsultationScreen(
        selectedCustomer: customerWithPets.header,
        selectedPets: customerWithPets.detail,
      ),
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<CustomerProvider>().setSearchQuery(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          final customers = provider.filteredCustomers;
          if (provider.isLoading && customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return _buildErrorMessage(provider.errorMessage!, provider.fetchCustomers);
          }
          if (customers.isEmpty) {
            return _buildEmptyCustomerList(isSearching: provider.searchQuery.isNotEmpty);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(provider, customers);
              } else {
                return _buildMobileLayout(provider, customers);
              }
            },
          );
        },
      ),
    );
  }

  // Corrected _buildAppBar method
AppBar _buildAppBar() {
  return AppBar(


    leading: Icon(Icons.pets),
    // THE FIX: Conditionally display the search field or the title.
    title: _isSearching
        ? _buildSearchField()
        : Text(widget.isSelectionMode ? 'Select Customer' : 'Customers'),
    backgroundColor: cardColor,
    foregroundColor: textColorPrimary,
    elevation: 1,
    actions: _isSearching
        ? [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close Search',
              onPressed: () {
                _searchController.clear();
                // THE FIX #2: Add setState to exit search mode and hide the text field.
                setState(() => _isSearching = false); 
              },
            ),
          ]
        : [
            if (!widget.isSelectionMode)
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Add New Customer',
                onPressed: _navigateToAddCustomer,
              ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search Customers',
              onPressed: () => setState(() => _isSearching = true),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => context.read<CustomerProvider>().fetchCustomers(),
            ),
          ],
  );
}
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by name or phone...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: textColorSecondary.withOpacity(0.8)),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildWebLayout(CustomerProvider provider, List<CustomerWithPets> customers) {
    if (_selectedCustomer == null && customers.isNotEmpty && !widget.isSelectionMode) {
      _selectedCustomer = customers.first;
    }
    if (_selectedCustomer != null && !customers.any((c) => c.header.customerId == _selectedCustomer!.header.customerId)) {
       _selectedCustomer = customers.isNotEmpty ? customers.first : null;
    }

    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Column(
            children: [
              if (_showFilters) _buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isSelected = customer.header.customerId == _selectedCustomer?.header.customerId;
                    return _buildMasterListItem(customer, isSelected);
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: widget.isSelectionMode
              ? const Center(child: Text('Select a customer from the list.'))
              : _selectedCustomer != null
                  ? _buildDetailPanel(_selectedCustomer!)
                  : const Center(child: Text('Select a customer to see details')),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(CustomerProvider provider, List<CustomerWithPets> customers) {
    return RefreshIndicator(
      onRefresh: provider.fetchCustomers,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (_showFilters) _buildFilterHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(smallPadding / 2),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMobileCustomerTile(customers[index]),
                childCount: customers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterListItem(CustomerWithPets customer, bool isSelected) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: smallPadding, vertical: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      color: isSelected ? primaryColor.withOpacity(0.1) : cardColor,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        // UPDATED onTap logic
        onTap: () {
          if (widget.isSelectionMode) {
            Navigator.of(context).pop(customer);
          } else {
            setState(() => _selectedCustomer = customer);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        leading: _buildAvatar(customer.header.fullName),
        title: Text(customer.header.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(customer.header.phone, style: const TextStyle(color: textColorSecondary, fontSize: 12)),
        selected: isSelected,
      ),
    );
  }
  
  // The rest of the file (_buildDetailPanel, etc.) remains largely the same but can be simplified for selection mode
  Widget _buildDetailPanel(CustomerWithPets customerWithPets) {
    // This panel is not shown in selection mode on web, so no changes needed here.
    final customer = customerWithPets.header;
    final pets = customerWithPets.detail;
    final formattedCreateDate = DateFormat('MMMM d, y').format(customer.createDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Customer'),
                onPressed: () => _navigateToUpdateCustomer(customer),
              ),
            ],
          ),
          const SizedBox(height: 2.0),
          Text(customer.phone, style: const TextStyle(fontSize: 14, color: textColorSecondary)),
          const Divider(height: defaultPadding * 1.5),
          const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: smallPadding),
          _buildDetailRow('Email', customer.email ?? 'N/A'),
          _buildDetailRow('Address', customer.address),
          _buildDetailRow('Member Since', formattedCreateDate),
          const Divider(height: defaultPadding * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Registered Pets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Pet'),
                onPressed: () => _navigateToAddPet(customer.customerId),
              ),
            ],
          ),
          const SizedBox(height: 2.0),
          if (pets.isEmpty)
            const Text('No pets registered for this customer.', style: TextStyle(color: textColorSecondary))
          else
            ...pets.map((pet) => _buildPetListItem(pet)),
          const SizedBox(height: defaultPadding),
          ElevatedButton.icon(
            onPressed: () => _navigateToConsultation(customerWithPets),
            icon: const Icon(Icons.medical_services_outlined),
            label: const Text('Start New Consultation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileCustomerTile(CustomerWithPets customerWithPets) {
    final customer = customerWithPets.header;
    final pets = customerWithPets.detail;

    // In selection mode, make the whole tile a simple, tappable button
    if (widget.isSelectionMode) {
      return Card(
        margin: const EdgeInsets.only(bottom: smallPadding / 2),
        child: ListTile(
          leading: _buildAvatar(customer.fullName),
          title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(customer.phone, style: const TextStyle(color: textColorSecondary, fontSize: 12)),
          onTap: () {
            Navigator.of(context).pop(customerWithPets);
          },
        ),
      );
    }
    
    // Normal mode with ExpansionTile
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: smallPadding / 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: ExpansionTile(
        shape: const Border(),
        leading: _buildAvatar(customer.fullName),
        title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(customer.phone, style: const TextStyle(color: textColorSecondary, fontSize: 12)),
        trailing: _buildPetCountBadge(pets.length),
        children: [_buildMobileTileDetails(customerWithPets)],
      ),
    );
  }

  // The rest of the helper widgets (_buildMobileTileDetails, etc.) can remain the same.
    Widget _buildMobileTileDetails(CustomerWithPets customerWithPets) {
    final customer = customerWithPets.header;
    final pets = customerWithPets.detail;
    final formattedCreateDate = DateFormat('MMMM d, y').format(customer.createDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(defaultPadding, 0, defaultPadding, smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
            _buildDetailRow('Email', customer.email ?? 'N/A'),
            _buildDetailRow('Address', customer.address),
            _buildDetailRow('Member Since', formattedCreateDate),
          const SizedBox(height: smallPadding),
          if (pets.isNotEmpty) ...[
            const Text('Pets', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2.0),
            ...pets.map((pet) => _buildPetListItem(pet)),
          ],
          const SizedBox(height: smallPadding),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToAddPet(customer.customerId),
                  child: const Text('Add Pet'),
                ),
              ),
              const SizedBox(width: smallPadding),
                Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToUpdateCustomer(customer),
                  child: const Text('Edit Customer'),
                ),
              ),
            ],
          ),
            const SizedBox(height: 2.0),
            ElevatedButton.icon(
              onPressed: () => _navigateToConsultation(customerWithPets),
              icon: const Icon(Icons.medical_services_outlined, size: 16),
              label: const Text('Start Consultation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 38),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetListItem(PetModel pet) {
    final age = (DateTime.now().difference(pet.birthDate).inDays / 365).floor();
    final isMale = pet.gender.toLowerCase() == 'male';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    pet.petName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: primaryColorDark),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: primaryColor),
                  tooltip: 'Edit Pet',
                  onPressed: () => _navigateToUpdatePet(pet),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 8.0,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 2.0,
              children: [
                  _buildPetDetailCell(
                    Icons.pets_outlined,
                    'Species:',
                    pet.species,
                 ),
                  _buildPetDetailCell(
                    Icons.pets,
                    'Breed:',
                    pet.breed,
                 ),
                  _buildPetDetailCell(
                    isMale ? Icons.male : Icons.female,
                    'Gender:',
                    pet.gender,
                 ),
                  _buildPetDetailCell(
                    Icons.cake_outlined,
                    'Age:',
                    '$age years',
                 ),
                  _buildPetDetailCell(
                    Icons.scale_outlined,
                    'Weight:',
                    '${pet.weight} kg',
                 ),
                  _buildPetDetailCell(
                    Icons.color_lens_outlined,
                    'Color:',
                    pet.color,
                 ),
                  _buildPetDetailCell(
                    Icons.health_and_safety_outlined,
                    'Status:',
                    pet.spayedNeutered ? 'Yes' : 'No',
                 ),
                  _buildPetDetailCell(
                    Icons.event_available,
                    'Registered:',
                    DateFormat('d MMM y').format(pet.createDate),
                 ),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildPetDetailCell(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: primaryColor),
        const SizedBox(width: 2.0),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: textColorSecondary),
        ),
        const SizedBox(width: 2.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String fullName) {
    final initials = fullName.isNotEmpty ? fullName.trim().split(' ').map((l) => l[0]).take(2).join() : 'C';
    return CircleAvatar(
      radius: 20,
      backgroundColor: primaryColor.withOpacity(0.2),
      child: Text(initials.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColorDark)),
    );
  }

  Widget _buildPetCountBadge(int petCount) {
    if (petCount == 0) return const SizedBox.shrink();
    return Chip(
      label: Text('$petCount ${petCount == 1 ? "Pet" : "Pets"}'),
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: primaryColorDark, fontWeight: FontWeight.w600, fontSize: 10),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: textColorSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverFilterHeaderDelegate(child: _buildFilterBar()),
    );
  }
  
  Widget _buildFilterBar() {
    final activeFilter = context.select((CustomerProvider p) => p.activeFilter);
    return Container(
      color: cardColor.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(horizontal: smallPadding, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip('All', activeFilter == 'All'),
          _buildFilterChip('With Pets', activeFilter == 'With Pets'),
          _buildFilterChip('No Pets', activeFilter == 'No Pets'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding / 2),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (isSelected) {
          if (isSelected) context.read<CustomerProvider>().setFilter(label);
        },
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: selected ? Colors.white : textColorPrimary),
      ),
    );
  }

  Widget _buildErrorMessage(String message, VoidCallback onRetry) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: smallPadding),
        const Text('Error Loading Customers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2.0),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: textColorSecondary)),
        const SizedBox(height: smallPadding),
        ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Try Again'), onPressed: onRetry),
      ]),
    ));
  }

  Widget _buildEmptyCustomerList({required bool isSearching}) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(isSearching ? Icons.search_off : Icons.people_outline, size: 64, color: Colors.grey[400]),
        const SizedBox(height: smallPadding),
        Text(isSearching ? 'No Customers Match' : 'No Customers Yet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2.0),
        Text(isSearching ? 'Try a different name or phone number.' : 'Tap the + button to add your first customer.', textAlign: TextAlign.center, style: const TextStyle(color: textColorSecondary)),
      ]),
    ));
  }
}

class _SliverFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverFilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext, double, bool) => child;
  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _SliverFilterHeaderDelegate oldDelegate) => child != oldDelegate.child;
}