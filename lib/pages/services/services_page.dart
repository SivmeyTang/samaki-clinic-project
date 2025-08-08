import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/components/section_title.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

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
            const HeroServiceSection(),

            // Service Section
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Text(
                    'Hight Quality Care',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Justified, centered, and width-constrained paragraph
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'Your pet is an integral part of your family, and when he or she is ill, you want the best medical care available. '
                          'The veterinarians and staff at All Paws Veterinary Clinic are ready to provide your pet with cutting-edge veterinary medical care. '
                          'Your dog or cat will receive high-quality care at our hospital, from wellness exams and vaccines to advanced diagnostics and complex surgical procedures.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cards Grid (Centered & Width Constrained)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          _petData.length,
                          (index) => ServiceCard(
                            imagePath: _petData[index]['image']!,
                            description: _petData[index]['description']!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // View All Services Button
            const SizedBox(height: 32),
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
                  context.go('/pet-care'); // ✅ Updated route
                },
                child: const Text('VIEW PET CARE'),
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

// ✅ ServiceCard with full-width image on top
class ServiceCard extends StatefulWidget {
  final String imagePath;
  final String description;

  const ServiceCard({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full-width top image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              widget.imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                  'Surgery',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3EFFF),
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? 'SHOW LESS' : 'LEARN MORE'),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.description,
                      style: const TextStyle(fontSize: 13),
                      textAlign: TextAlign.justify,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy pet data (image + description)
final List<Map<String, String>> _petData = [
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'Ultrasound uses high-frequency sound waves to capture live images from the inside of your pet’s body.',
  },
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'Our surgery suite is fully equipped for a wide range of procedures with experienced veterinary surgeons.',
  },
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'We provide dental cleanings and oral exams to ensure your pet’s dental hygiene and health.',
  },
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'We monitor all vital signs during surgery to ensure your pet’s safety at all times.',
  },
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'Soft tissue surgeries include procedures on the skin, muscles, and internal organs of your pet.',
  },
  {
    'image': 'assets/cover_service.jpg',
    'description':
        'Our recovery rooms are temperature-controlled and closely monitored for post-operative comfort.',
  },
];
