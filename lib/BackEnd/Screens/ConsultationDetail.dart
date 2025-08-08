// lib/Screens/ConsultationDetailScreen.dart

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../Model/ConsultationModel.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final ConsultationModel consultation;

  const ConsultationDetailScreen({Key? key, required this.consultation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper to format dates consistently
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${consultation.header.petName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for Owner & Pet Details
            _buildInfoCard(
              context: context,
              title: 'Owner & Patient Info',
              icon: Icons.person_pin_circle_outlined,
              children: [
                _buildDetailRow('Owner Name:', consultation.header.customerName),
                _buildDetailRow('Owner Phone:', consultation.header.phone),
                const Divider(height: 20),
                _buildDetailRow('Pet Name:', consultation.header.petName),
                _buildDetailRow('Species:', consultation.header.species),
                _buildDetailRow('Breed:', consultation.header.breed),
                _buildDetailRow('Gender:', consultation.header.gender),
              ],
            ),
            const SizedBox(height: 16),

            // Section for Medical Notes
            _buildInfoCard(
              context: context,
              title: 'Medical Notes',
              icon: Icons.medical_services_outlined,
              children: [
                _buildDetailRow('Consultation Date:',
                    formatter.format(consultation.header.postingDate)),
                const SizedBox(height: 8),
                Text(
                  consultation.header.historiesTreatment.isNotEmpty
                      ? consultation.header.historiesTreatment
                      : 'No treatment notes were recorded.',
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section for Immunization Records
            _buildInfoCard(
              context: context,
              title: 'Immunization Records',
              icon: Icons.vaccines_outlined,
              children: consultation.detail.isEmpty
                  ? [const Text('No immunization records for this visit.')]
                  : consultation.detail.map((immunization) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                immunization.immunizationType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              const Divider(height: 12),
                              _buildDetailRow('Given Date:',
                                  formatter.format(immunization.givenDate)),
                              _buildDetailRow('Next Due Date:',
                                  formatter.format(immunization.nextDueDate)),
                              _buildDetailRow('Notify Date:',
                                  formatter.format(immunization.notifyDate)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create styled cards for each section
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper widget to format each row of details consistently
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Consistent width for labels
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}