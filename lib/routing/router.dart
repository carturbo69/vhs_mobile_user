import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.listService,
  routes: [
    GoRoute(
      path: Routes.listService,
      builder: (context, state) => const ServiceListScreen(),
    ),
    GoRoute(
      path: Routes.detailService,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceDetailPage(id: id);
      },
    ),
  ],
);
