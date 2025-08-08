import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:samaki_clinic/pages/appointment/appointment_page.dart';
import 'package:samaki_clinic/pages/home/home_page.dart';
import 'package:samaki_clinic/pages/about/about_page.dart';
import 'package:samaki_clinic/pages/pet_care/pet_care_page.dart';
import 'package:samaki_clinic/pages/services/services_page.dart';

void main() {
  runApp(const MyApp());
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
        return AppointmentPage(from: from);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
