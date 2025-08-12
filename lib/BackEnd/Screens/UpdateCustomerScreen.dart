import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Model/CustomerList_Model.dart';
import 'package:samaki_clinic/BackEnd/Model/customer_add_model.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerUpdateProvider.dart';

class UpdateCustomerScreen extends StatefulWidget {
  final CustomerModel customer;

  const UpdateCustomerScreen({super.key, required this.customer});

  @override
  State<UpdateCustomerScreen> createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);
    _emailController = TextEditingController(text: widget.customer.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (!mounted || !_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerUpdateProvider>();

    // ✅ Use CustomerHeader here (not CustomerModel)
    final updatedCustomer = CustomerHeader(
      customerId: widget.customer.customerId,
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      title: widget.customer.title,
      createDate: widget.customer.createDate,
    );

    final success = await provider.updateCustomer(updatedCustomer);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Customer Updated Successfully!'),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Update failed: ${provider.error ?? "Unknown error"}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerUpdateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: provider.isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
