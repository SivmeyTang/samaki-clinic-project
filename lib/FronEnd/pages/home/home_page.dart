import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/FronEnd/components/section_title.dart';
import 'package:samaki_clinic/FronEnd/pages/home/widgets/about_section.dart';
import 'package:samaki_clinic/FronEnd/pages/home/widgets/petcare_section.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart';
import 'widgets/service_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F9FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //header section
            const NavBar(),

            // Hero Section
            const HeroHomeSection(),

            // About Section (Updated with expandable "More About Us")
            const AboutSection(),

            // Services Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Our Veterinary Services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Only this text is centered and constrained
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 755),
                      child: const Text(
                        'We provide a full range of veterinary services designed to support every stage of your pet’s life. From wellness check-ups and vaccinations to diagnostics, surgery, and emergency care, our team is here to ensure your pet receives the highest standard of treatment in a calm and caring environment.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Image slider (not affected by center/constrained width)
                  const SizedBox(
                    height: 210,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ServiceImage(
                            title: 'Pet Anesthesia',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Dental Care',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Vaccinations',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Check-ups',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Emergency Care',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Emergency Care',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                          SizedBox(width: 16),
                          ServiceImage(
                            title: 'Emergency Care',
                            imagePath: 'assets/cover_service.jpg',
                          ),
                        ],
                      ),
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
                      context.go('/services'); // ✅ Updated route
                    },
                    child: const Text('VIEW ALL SERVICES'),
                  ),
                ],
              ),
            ),

            //Pet Care Section
            const PetCareSection(),

            //footer section
            const Footer(),
          ],
        ),
      ),
    );
  }
}
