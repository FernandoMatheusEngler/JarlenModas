import 'package:go_router/go_router.dart';
import 'package:jarlenmodas/pages/client/client_page/client_page.dart';
import 'package:jarlenmodas/pages/client/debit_client/debit_client_page.dart';
import 'package:jarlenmodas/pages/home/home_page.dart';
import 'package:jarlenmodas/pages/login/login_page.dart';
import 'package:jarlenmodas/widgets/layout_controller/layout_widget.dart';

class AllRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/login', // Rota inicial
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => LayoutWidget(content: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/create-client',
            name: 'create-client',
            builder: (context, state) => const ClientPage(),
          ),
          GoRoute(
            path: '/debit-client',
            name: 'debit-client',
            builder: (context, state) => const DebitClientPage(),
          ),
        ],
      ),
    ],
  );
}
