import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/BackEnd/Screens/CreateAppointmentScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'footer.dart'; // Make sure to import the footer where the key is defined

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final isTablet =
            constraints.maxWidth >= 800 && constraints.maxWidth < 1100;

        final double navFontSize = isMobile
            ? 16
            : isTablet
                ? 20
                : 27;

        final double logoSize = isMobile
            ? 50
            : isTablet
                ? 60
                : 72;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top contact bar
            Container(
              color: const Color(0xFFA1E3F9),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: isMobile
                  ? Column(
                      children: const [
                        _ContactRow(),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ContactRow(),
                      ],
                    ),
            ),

            // Main nav bar with logo in the middle
            Container(
              color: Colors.blue[50],
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 18,
                vertical: isMobile ? 8 : 10,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _navItem(context, 'Home', '/', navFontSize),
                            _navItem(
                                context, 'About us', '/about', navFontSize),
                            _navItem(
                                context, 'Services', '/services', navFontSize),
                            _navItem(
                                context, 'Pet Care', '/pet-care', navFontSize),
                            _navItem(
                                context, 'Contact', '#footer', navFontSize),
                            _navItem(context, 'Appointment', '/appointment',
                                navFontSize),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipOval(
                          child: Image.asset(
                            'assets/logo.jpg',
                            height: logoSize,
                            width: logoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _bookButton(context),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _navItem(context, 'Home', '/', navFontSize),
                        _navItem(context, 'About us', '/about', navFontSize),
                        _navItem(context, 'Services', '/services', navFontSize),
                        // Wrap your Padding with an InkWell to make it tappable
                    InkWell(
                      onTap: () {
                        // This is the navigator action 👆
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      // This makes the tap ripple effect circular to match your image
                      customBorder: const CircleBorder(), 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpg',
                            height: logoSize, // Assuming 'logoSize' is defined
                            width: logoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                        _navItem(context, 'Pet Care', '/pet-care', navFontSize),
                        _navItem(context, 'Contact', '#footer', navFontSize),
                        const SizedBox(width: 10),
                        _bookButton(context),
                      ],
                    ),
            ),

            // Bottom tagline
            Container(
              color: const Color(0xFFA1E3F9),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Center(
                child: Text(
                  'Compassionate care for your pets, because they\'re family.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _bookButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC3EFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      ),
      onPressed: () {
        final currentPath = GoRouterState.of(context).uri.path;
        context.go('/appointment?from=${Uri.encodeComponent(currentPath)}');
      },
      child: const Text(
        'Book Appointment',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget _navItem(
      BuildContext context, String label, String path, double fontSize) {
    if (path == '#footer') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: TextButton(
          onPressed: () {
            final renderObject = footerKey.currentContext?.findRenderObject();
            if (renderObject != null) {
              renderObject.showOnScreen(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: () => context.go(path),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _launchFacebook() async {
    const facebookUrl =
        'https://www.facebook.com/share/1Gdwx7f6tN/?mibextid=wwXIfr';
    if (await canLaunchUrl(Uri.parse(facebookUrl))) {
      await launchUrl(Uri.parse(facebookUrl));
    } else {
      throw 'Could not launch $facebookUrl';
    }
  }

  Future<void> _launchTelegram() async {
    const telegramUrl = 'https://t.me/your_telegram';
    if (await canLaunchUrl(Uri.parse(telegramUrl))) {
      await launchUrl(Uri.parse(telegramUrl));
    } else {
      throw 'Could not launch $telegramUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: isMobile ? 16 : 24,
      runSpacing: 4,
      children: [
        // Phone with text
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () => _makePhoneCall('+85516467971'),
            ),
            GestureDetector(
              onTap: () => _makePhoneCall('+85516467971'),
              child: Text(
                '+855 16 467 971',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ],
        ),

        // Email with text
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.email, color: Colors.white),
              onPressed: () => _sendEmail('samaki@gmail.com'),
            ),
            GestureDetector(
              onTap: () => _sendEmail('samaki@gmail.com'),
              child: Text(
                'samaki@gmail.com',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ],
        ),

        // Facebook icon only
        IconButton(
          icon: const Icon(Icons.facebook, color: Colors.white),
          onPressed: _launchFacebook,
        ),

        // Telegram icon only
        IconButton(
          icon: const Icon(Icons.telegram, color: Colors.white),
          onPressed: _launchTelegram,
        ),
      ],
    );
  }
}
