import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

final GlobalKey footerKey = GlobalKey();

class Footer extends StatelessWidget {
  const Footer({super.key});

  // Enhanced map launch function with multiple fallbacks
  Future<void> _openMap(BuildContext context) async {
    const clinicLat = 11.576026;
    const clinicLng = 104.888605;

    // Try multiple URL formats in sequence
    final urlsToTry = [
      Uri.parse("https://maps.app.goo.gl/tVb4wkLSF48Zi3F39"),
      Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$clinicLat,$clinicLng"),
      Uri.parse("https://maps.apple.com/?q=$clinicLat,$clinicLng"),
    ];

    for (final url in urlsToTry) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('Failed to launch URL: $e');
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch maps application'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    final LatLng clinicLatLng = const LatLng(11.576026, 104.888605);

    return Column(
      key: footerKey,
      children: [
        // Appointment CTA Section
        Container(
          padding: EdgeInsets.all(isMobile ? 16.0 : 26.0),
          width: double.infinity,
          color: const Color(0xFFA1E3F9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Book An Appointment',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'At Samaki Veterinary Clinic, we take veterinary medicine to the next level by paying '
                'attention to your pets\' needs and understanding your concerns. Please book an appointment for '
                'your pet using our online system.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3EFFF),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 28,
                    vertical: isMobile ? 12 : 14,
                  ),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                    letterSpacing: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  final currentPath = GoRouterState.of(context).uri.path;
                  context.go(
                      '/appointment?from=${Uri.encodeComponent(currentPath)}');
                },
                child: const Text('BOOK APPOINTMENT'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Divider Line
        Container(
          width: isMobile ? 300 : 450,
          height: 5,
          color: const Color(0xFFC8C8C8),
        ),

        const SizedBox(height: 18),

        // Map and Contact Info Section
        Container(
          color: const Color(0xFFC3EFFF),
          child: isMobile
              ? Column(
                  children: [
                    // Mobile Map with Directions Button
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _openMap(context),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: clinicLatLng,
                                initialZoom: 16,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: clinicLatLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _openMap(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.directions, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text('Directions',
                                        style: TextStyle(color: Colors.blue)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: _buildContactInfo(isMobile: true),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop/Tablet Map with Directions Button
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: isTablet ? 350 : 370,
                        child: Stack(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _openMap(context),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: clinicLatLng,
                                    initialZoom: isTablet ? 16 : 17,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: clinicLatLng,
                                          width: 50,
                                          height: 50,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: FloatingActionButton.small(
                                onPressed: () => _openMap(context),
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.directions,
                                    color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 12 : 18),
                        child: _buildContactInfo(isMobile: false),
                      ),
                    ),
                  ],
                ),
        ),

        // Copyright Section
        Container(
          color: Colors.blueGrey.shade50,
          padding: const EdgeInsets.all(6),
          child: Center(
            child: Text(
              '© 2025 Samaki Veterinary Clinic - All rights reserved.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Samaki Veterinary Clinic',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '271st, Neangket Village, Russey Krok Commune,\n'
                'Mongkulborey District, Banteaymeanchey Province, Cambodia.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              '0963055463',
              style: TextStyle(
                color: Colors.black,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.email, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              'samaki@gmail.com',
              style: TextStyle(
                color: Colors.black,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.access_time_filled, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOpeningTime('Monday', isMobile),
                  _buildOpeningTime('Tuesday', isMobile),
                  _buildOpeningTime('Wednesday', isMobile),
                  _buildOpeningTime('Thursday', isMobile),
                  _buildOpeningTime('Friday', isMobile),
                  _buildOpeningTime('Saturday', isMobile),
                  _buildOpeningTime('Sunday', isMobile),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpeningTime(String day, bool isMobile) {
    return Text(
      '$day: 8:00 am - 6:00 pm',
      style: TextStyle(
        color: Colors.black,
        fontSize: isMobile ? 14 : 16,
      ),
    );
  }
}
