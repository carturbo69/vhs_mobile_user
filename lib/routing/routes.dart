abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const listService = '/list-service';
  static const detailService = '/services/:id';
  static String detailServicePath(String id) => '/services/$id';
  // Add other routes here
}
