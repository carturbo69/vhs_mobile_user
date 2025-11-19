import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/service/service_list_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.listService,
  routes: [
    GoRoute(
      path: Routes.listService,
      builder: (context, state) => const ServiceListScreen(),
    ),
  ],
);
