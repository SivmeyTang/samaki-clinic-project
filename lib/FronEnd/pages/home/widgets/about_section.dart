import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  final String fullText =
      'At Our Samaki Veterinary Clinic, we believe every pet deserves compassionate and personalized care. Our team of experienced veterinarians and dedicated staff work together to create a welcoming space where pets feel safe and owners feel confident. From preventive care to advanced treatments, we’re committed to building lasting relationships with our clients and their furry companions.';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/home_about.jpg',
                      fit: BoxFit.cover,
                      height: 360,
                    ),
                  ),
                ),

                const SizedBox(width: 32),

                // Right: Text and Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Samaki Veterinary Clinic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'About Our Samaki Veterinary Clinic',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          fullText,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
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
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          context.go('/about'); // ✅ Updated route
                        },
                        child: const Text('MORE ABOUT US'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
