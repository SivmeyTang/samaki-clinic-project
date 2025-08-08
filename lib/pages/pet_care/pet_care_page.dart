import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/components/section_title.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart';

class PetCarePage extends StatelessWidget {
  const PetCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F9FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NavBar(),

            const HeroPetCareSection(),

            // Section 1: Introduction
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 180, vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.pets, size: 36, color: Colors.black87),
                  const SizedBox(height: 12),
                  const Text(
                    'All Cats Welcome at\nOur Cat Friendly Practice',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // ✅ Align vertically
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'As a cat owner, you know how anxious your feline friend can be about veterinary visits—and the car ride over. '
                              'Unfortunately, due to many cats'
                              ' fears and anxieties over veterinary visits, far fewer of them receive annual wellness care '
                              'than their canine counterparts. At Samaki Veterinary Clinic, we want to change that. By obtaining certification as a '
                              'Gold Standard Cat Friendly Practice, we'
                              've gone through the extra steps to make our hospital accommodating to felines.',
                              style: TextStyle(fontSize: 16, height: 1.5),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/logo.jpg',
                                  height: 180,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center, // ✅ Middle align
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/pet_care.png',
                              height: 270,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Section 2: Certification Features
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 180, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What Does Cat Friendly Certification Mean?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cat Friendly Practices receive accreditation from the American Association of Feline Practitioners (AAFP). '
                    'This organization sets the highest standards for feline medicine and care. As a Gold Standard Cat Friendly Practice, '
                    'we have not only met the essential criteria for becoming cat friendly; we have gone even further to incorporate '
                    'cat-friendly elements in every level of our practice.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (var text in [
                        "Creating cat-friendly waiting areas and exam rooms",
                        "Compassionate interaction with cat owners",
                        "Stress-free handling of cats",
                        "Ongoing feline medicine education",
                        "Feline-specific preventive care",
                        "Stress-free boarding of cats",
                        "Feline-specific anesthesia protocols",
                        "Cat-size surgical tools"
                      ])
                        SizedBox(
                          width: (MediaQuery.of(context).size.width -
                                  180 * 2 -
                                  72) /
                              4,
                          child: _featureTile(text),
                        )
                    ],
                  ),
                ],
              ),
            ),

            // Section 3: Benefits (updated and aligned version)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 81, vertical: 32),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Changed to start
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Benefits of Bringing Your Cat to a Cat Friendly Practice',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'At our feline-friendly hospital, we strive to make our feline patients comfortable and relaxed. Some of the benefits include:',
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 12),
                        BulletList(items: [
                          'Stress-free handling of your feline friend',
                          'Cat-only exam rooms and dog-free waiting areas',
                          'Treats to encourage cooperation',
                          'Pheromone sprays to help your cat relax',
                          'Staff educated in feline medicine and behavior',
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/cat_friendly.jpeg',
                        height: 280, // Fixed height
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section 4: Tips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 81, vertical: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/stress_free_cat.jpg',
                        height: 280, // Same height as above
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tips for a Stress-Free Journey',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'We know that stress begins at home for many cats and cat owners. That'
                          's why we offer advice and tips for getting to the vet with as little stress. Some include:',
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 12),
                        BulletList(items: [
                          'Leave the carrier out all the time or at least a day or two before the visit.',
                          'Line the carrier with soft items that smell like home and hide a treat or two inside.',
                          'Give yourself plenty of time so you'
                              're not rushed getting to the appointment.',
                          'Cover the carrier with a blanket or towel during travel to keep things dark and quiet.',
                          'Ask your vet about anxiety relief options and calming products to support your cat'
                              's visit.',
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3EFFF),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  context.go('/');
                },
                child: const Text('BACK TO HOME',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 36),

            const Footer(),
          ],
        ),
      ),
    );
  }

  static Widget _featureTile(String text) {
    IconData icon;
    if (text.contains("waiting") || text.contains("exam"))
      icon = Icons.event_seat;
    else if (text.contains("Compassionate"))
      icon = Icons.favorite;
    else if (text.contains("handling"))
      icon = Icons.pets;
    else if (text.contains("education"))
      icon = Icons.school;
    else if (text.contains("preventive"))
      icon = Icons.shield;
    else if (text.contains("boarding"))
      icon = Icons.hotel;
    else if (text.contains("anesthesia"))
      icon = Icons.medical_services;
    else if (text.contains("surgical"))
      icon = Icons.build;
    else
      icon = Icons.check_circle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 36, color: Colors.teal),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;
  const BulletList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(item, style: TextStyle(height: 1.4))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
