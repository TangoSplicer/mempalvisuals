import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/capture/presentation/screens/capture_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/graph/presentation/screens/graph_screen.dart';
import '../../features/palace/presentation/screens/palace_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/capture',
      builder: (context, state) => const CaptureScreen(),
    ),
    GoRoute(
      path: '/graph',
      builder: (context, state) => const GraphScreen(),
    ),
    GoRoute(
      path: '/palace',
      builder: (context, state) => const PalaceScreen(),
    ),
    GoRoute(
      path: '/timeline',
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);
