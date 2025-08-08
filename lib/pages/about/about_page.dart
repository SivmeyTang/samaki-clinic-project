import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/components/section_title.dart';
import 'package:samaki_clinic/pages/about/widgets/team_section.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F9FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            const NavBar(),

            // Hero Section
            const HeroAboutSection(),

            // Our Story Section
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: title + subtitle + text
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            title: 'Who Are We?',
                            subtitle: 'Get to know about our story!',
                            alignment: CrossAxisAlignment.start,
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'Samaki Veterinary Clinic is a compassionate and dedicated animal care provider located in the heart of Phnom Penh. Our mission is to offer comprehensive veterinary services to ensure the health and well-being of your beloved pets. We understand that pets are family, and we treat them with the utmost care and respect.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.justify, // <-- added
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40.0),
                    // Right: image
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/who_are_we.jpg',
                          fit: BoxFit.cover,
                          height: 360,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Our Veterinary Team Section
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/our_veterinary_team.jpg',
                          fit: BoxFit.cover,
                          height: 360,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40.0),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            title: 'Our Veterinary Team',
                            subtitle: 'Meet Our Veterinarians and Staff',
                            alignment: CrossAxisAlignment.start,
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'Our team comprises skilled and compassionate veterinarians and support staff committed to delivering the highest standard of care. With expertise in various aspects of veterinary medicine, we are equipped to handle a wide range of health concerns, from routine check-ups to emergency treatments. We prioritize continuous learning and stay updated with the latest advancements in veterinary science to provide the best possible care for your pets.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.justify, // <-- added
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Our Reviews Section
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: title + subtitle + text
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            title: 'Our Reviews',
                            subtitle: 'Thank You for Your Kind Words!',
                            alignment: CrossAxisAlignment.start,
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'While specific reviews are not detailed in the available information, our clinic\'s reputation is built on trust, professionalism, and a genuine love for animals. We encourage you to visit our Facebook page to see firsthand accounts from our satisfied clients. Their testimonials reflect our commitment to excellence and the strong bond we share with the pet community.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.justify, // <-- added
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40.0),
                    // Right: image
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/our_review.jpg',
                          fit: BoxFit.cover,
                          height: 360,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // View All Services Button (centered and auto-width)
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3EFFF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  context.go('/services'); // ✅ Updated route
                },
                child: const Text('VIEW ALL SERVICES'),
              ),
            ),
            const SizedBox(height: 40),

            // Footer section
            const Footer(),
          ],
        ),
      ),
    );
  }
}
