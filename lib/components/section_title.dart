import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroHomeSection extends StatelessWidget {
  const HeroHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background image
        Image.asset(
          'assets/cover_home_page.jpg',
          fit: BoxFit.cover,
          height: isMobile ? 400 : 500,
          width: double.infinity,
        ),

        // Text content overlay
        Positioned(
          left: isMobile ? 20 : 50,
          top: isMobile ? 50 : 100,
          child: Container(
            padding: isMobile ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Samaki Veterinary${isMobile ? ' ' : '\n'}Clinic',
                  style: TextStyle(
                    fontSize: isMobile
                        ? 24
                        : isTablet
                            ? 28
                            : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isMobile
                      ? screenSize.width * 0.9
                      : isTablet
                          ? 400
                          : 500,
                  child: Text(
                    'Your trusted partner in pet health and wellness. Located in Phnom Penh, we’re dedicated to providing gentle, high-quality veterinary care in a friendly and caring environment for both you and your beloved pet.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final currentPath = GoRouterState.of(context).uri.path;
                    context.go(
                        '/appointment?from=${Uri.encodeComponent(currentPath)}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3EFFF),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HeroAboutSection extends StatelessWidget {
  const HeroAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background image
        Image.asset(
          'assets/cover_about_page.jpg',
          fit: BoxFit.cover,
          height: isMobile ? 400 : 500,
          width: double.infinity,
        ),

        // Text content overlay
        Positioned(
          left: isMobile ? 20 : 40,
          top: isMobile ? 50 : 100,
          child: Container(
            padding: isMobile ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Our',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Samaki Veterinary${isMobile ? ' ' : '\n'}Clinic',
                  style: TextStyle(
                    fontSize: isMobile
                        ? 24
                        : isTablet
                            ? 28
                            : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isMobile
                      ? screenSize.width * 0.9
                      : isTablet
                          ? 400
                          : 500,
                  child: Text(
                    'A place built on compassion, trust, and a deep love for animals. Based in Phnom Penh, we are proud to offer professional veterinary care delivered with a personal touch. Our story is rooted in a commitment to your pets’ well-being, and every day, our team works with heart to ensure they live happy, healthy lives.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final currentPath = GoRouterState.of(context).uri.path;
                    context.go(
                        '/appointment?from=${Uri.encodeComponent(currentPath)}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HeroServiceSection extends StatelessWidget {
  const HeroServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background image
        SizedBox(
          height: isMobile ? 400 : 500,
          width: double.infinity,
          child: Image.asset(
            'assets/cover_service.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // Dark overlay for contrast
        Container(
          height: isMobile ? 400 : 500,
          width: double.infinity,
          color: Colors.black.withOpacity(0.4),
        ),

        // Centered text and button
        Positioned(
          top: isMobile ? 150 : 180,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Samaki Veterinary Clinic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile
                      ? 28
                      : isTablet
                          ? 36
                          : 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final currentPath = GoRouterState.of(context).uri.path;
                  context.go(
                      '/appointment?from=${Uri.encodeComponent(currentPath)}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeroPetCareSection extends StatelessWidget {
  const HeroPetCareSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background image
        SizedBox(
          height: isMobile ? 400 : 500,
          width: double.infinity,
          child: Image.asset(
            'assets/cover_pet_care.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // Dark overlay for contrast
        Container(
          height: isMobile ? 400 : 500,
          width: double.infinity,
          color: Colors.black.withOpacity(0.4),
        ),

        // Centered text and button
        Positioned(
          top: isMobile ? 150 : 180,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Samaki Veterinary Clinic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pet Care',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile
                      ? 28
                      : isTablet
                          ? 36
                          : 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final currentPath = GoRouterState.of(context).uri.path;
                  context.go(
                      '/appointment?from=${Uri.encodeComponent(currentPath)}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
