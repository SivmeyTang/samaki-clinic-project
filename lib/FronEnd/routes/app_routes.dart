import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // You can enable About, Services etc later
  ],
);
