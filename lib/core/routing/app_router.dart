import 'package:go_router/go_router.dart';
import '../../features/graph/presentation/screens/graph_screen.dart';
import '../../features/palace/presentation/screens/palace_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/graph',
  routes: [
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
  ],
);
