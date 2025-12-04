import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/routing/router.dart';
import 'package:vhs_mobile_user/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Thư viện lõi
import 'data/services/notification_service.dart';
import 'firebase_options.dart'; // File cấu hình vừa được tạo tự động

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.initialize();
  runApp(const AppRoot());
}


//Hacking the way to reset all providers
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Key _providerScopeKey = UniqueKey();

  /// Gọi hàm này = RESET TẤT CẢ PROVIDERS
  void resetProviders() {
    _providerScopeKey = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _providerScopeKey,
      overrides: [appResetProvider.overrideWithValue(resetProviders)],
      child: MyApp(resetProviders: resetProviders),
    );
  }
}
final appResetProvider = Provider<VoidCallback>((ref) {
  throw UnimplementedError("resetProviders not set yet");
});

class MyApp extends ConsumerWidget {
  final VoidCallback resetProviders;
  const MyApp({super.key, required this.resetProviders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'VHS Mobile User',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Colors.blue.shade300,
          onPrimary: Colors.white,
          secondary: Colors.blue.shade200,
          onSecondary: Colors.black,
          error: Colors.red.shade400,
          onError: Colors.white,
          surface: const Color(0xFF1E1E1E),
          onSurface: Colors.white,
          surfaceContainerHighest: const Color(0xFF2D2D2D),
          onSurfaceVariant: Colors.grey.shade400,
          outline: Colors.grey.shade700,
          shadow: Colors.black,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.blue.shade300,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(color: Colors.blue),
          unselectedLabelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        dividerColor: Colors.grey.shade800,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.grey),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
