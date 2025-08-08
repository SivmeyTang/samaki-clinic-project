import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PetCareSection extends StatelessWidget {
  const PetCareSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE7F9FF),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Why Pet Care Matters to Your Furry Friends?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              // ignore: unused_local_variable
              bool isMobile = constraints.maxWidth < 768;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _buildCard(
                    icon: Icons.medical_services,
                    title: 'Prevents Illness',
                    description:
                        'Regular check-ups, grooming, and a balanced diet help prevent illness and catch health problems early, keeping your pet active and happy',
                  ),
                  _buildCard(
                    icon: Icons.emoji_emotions,
                    title: 'Builds Trust',
                    description:
                        'Spending time caring for your pet builds trust and affection. They feel safe, loved, and emotionally connected to you every day',
                  ),
                  _buildCard(
                    icon: Icons.water_drop,
                    title: 'Extends Lifespan',
                    description:
                        'Proper care leads to a longer life filled with comfort and joy. A healthy pet means more special moments shared with you.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC3EFFF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.go('/pet-care'); // ✅ Updated route
            },
            child: const Text('VIEW PET CARE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Color(0xFF189AB4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
