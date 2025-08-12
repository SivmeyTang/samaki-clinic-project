import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Screens/CreateAppointmentScreen.dart';
import 'package:samaki_clinic/BackEnd/logic/AppointmentProvider.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';
import 'package:samaki_clinic/BackEnd/logic/consultation_provider.dart';
import 'package:samaki_clinic/BackEnd/logic/customer_add_provider.dart';
import 'package:samaki_clinic/BackEnd/logic/product_provider.dart';
import 'package:samaki_clinic/FronEnd/models/appointment_page.dart';

import 'package:samaki_clinic/FronEnd/pages/home/home_page.dart';
import 'package:samaki_clinic/FronEnd/pages/about/about_page.dart';
import 'package:samaki_clinic/FronEnd/pages/pet_care/pet_care_page.dart';
import 'package:samaki_clinic/FronEnd/pages/services/services_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CustomerAddProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()..fetchConsultations()),
         ChangeNotifierProvider(create: (_) => AppointmentProvider ()),
      
      ],
      child: const MyApp(),
    ),
  );
}


final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicePage(),
    ),
    GoRoute(
      path: '/pet-care',
      builder: (context, state) => const PetCarePage(),
    ),
    GoRoute(
      path: '/appointment',
      builder: (context, state) {
        final from = state.uri.queryParameters['from'];
        return AppointmentPage();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Samaki Veterinary Clinic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Changed to a vibrant blue
          brightness: Brightness.light,
          primary: const Color(0xFF007AFF), // Primary blue color
          secondary: const Color(
            0xFFFFC107,
          ), // A contrasting amber for secondary
          tertiary: const Color(0xFF64FFDA), // A bright cyan for tertiary
          onPrimary: Colors.white, // Text color on primary color
          onSecondary: Colors.black87, // Text color on secondary color
          onTertiary: Colors.black87, // Text color on tertiary color
          surfaceTint: Colors.white, // For elevated surfaces in light mode
        ),
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 2, // Added subtle elevation
          scrolledUnderElevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 22, // Slightly smaller title
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          backgroundColor: Colors.white, // Ensure app bar has a background
          foregroundColor: Color(0xFF007AFF), // Blue app bar text
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 3,
          indicatorColor: const Color(0xFF007AFF).withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ), // Smaller font
          ),
        ),
        drawerTheme: const DrawerThemeData(elevation: 2),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Smaller card radius
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ), // Smaller radius
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ), // Smaller padding
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Smaller radius
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // Smaller padding
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Smaller radius
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ), // Smaller padding
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
