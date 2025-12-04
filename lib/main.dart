import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vhs_mobile_user/routing/router.dart';
import 'package:vhs_mobile_user/providers/theme_provider.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/l10n/app_localizations.dart';
import 'package:vhs_mobile_user/services/notification_service.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';

void main() {
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

class MyApp extends ConsumerStatefulWidget {
  final VoidCallback resetProviders;
  const MyApp({super.key, required this.resetProviders});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service and connect SignalR when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Initialize and connect notification SignalR
        print('🚀 Initializing notification service...');
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize();
        await notificationService.connectSignalR();
        print('✅ Notification SignalR connected');
        
        // Auto-connect chat SignalR with retry
        print('🚀 Auto-connecting chat SignalR...');
        final chatSignalRService = ref.read(signalRChatServiceProvider);
        
        // Retry up to 3 times with delay
        int retries = 0;
        const maxRetries = 3;
        while (retries < maxRetries && !chatSignalRService.isConnected) {
          await chatSignalRService.autoConnect();
          if (chatSignalRService.isConnected) {
            print('✅ Chat SignalR auto-connect successful on attempt ${retries + 1}');
            break;
          }
          retries++;
          if (retries < maxRetries) {
            print('⚠️ Chat SignalR auto-connect failed, retrying in 2 seconds... (attempt $retries/$maxRetries)');
            await Future.delayed(const Duration(seconds: 2));
          }
        }
        
        if (!chatSignalRService.isConnected) {
          print('⚠️ Chat SignalR auto-connect failed after $maxRetries attempts');
        } else {
          print('✅ Chat SignalR auto-connect completed');
          
          // Setup global chat listeners to receive messages even when not on chat screen
          final globalChatService = ref.read(globalChatServiceProvider);
          await globalChatService.setupListeners();
          print('✅ Global chat listeners setup completed');
        }
      } catch (e, stackTrace) {
        print('❌ Error initializing SignalR services: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Dịch vụ gia đình Việt',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
