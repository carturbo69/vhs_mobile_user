import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vhs_mobile_user/routing/router.dart';
import 'package:vhs_mobile_user/providers/theme_provider.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/l10n/app_localizations.dart';
import 'package:vhs_mobile_user/services/notification_service.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/ui/notification/notification_viewmodel.dart';

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
  bool _signalRInitialized = false;
  Timer? _notificationRefreshTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notificationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize SignalR when dependencies are ready
    if (!_signalRInitialized) {
      _signalRInitialized = true;
      _initializeSignalR();
    }
  }

  Future<void> _initializeSignalR() async {
    // Wait a bit to ensure ref is ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Initialize and connect notification SignalR
      print('🚀 [Main] Initializing notification service...');
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      print('✅ [Main] Notification service initialized');
      
      // Load notification list first to ensure it's ready
      final notificationNotifier = ref.read(notificationListProvider.notifier);
      await notificationNotifier.refresh();
      print('✅ [Main] Notification list loaded');
      
      await notificationService.connectSignalR();
      print('✅ [Main] Notification SignalR connected');
      
      // Setup auto-refresh notification list every 30 seconds (backup if SignalR fails)
      // Note: SignalR should handle real-time updates, this is just a backup
      _setupAutoRefreshNotifications();
      
      // Auto-connect chat SignalR with retry
      print('🚀 [Main] Auto-connecting chat SignalR...');
      final chatSignalRService = ref.read(signalRChatServiceProvider);
      
      // Retry up to 3 times with delay
      int retries = 0;
      const maxRetries = 3;
      while (retries < maxRetries && !chatSignalRService.isConnected) {
        await chatSignalRService.autoConnect();
        if (chatSignalRService.isConnected) {
          print('✅ [Main] Chat SignalR auto-connect successful on attempt ${retries + 1}');
          break;
        }
        retries++;
        if (retries < maxRetries) {
          print('⚠️ [Main] Chat SignalR auto-connect failed, retrying in 2 seconds... (attempt $retries/$maxRetries)');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      if (!chatSignalRService.isConnected) {
        print('⚠️ [Main] Chat SignalR auto-connect failed after $maxRetries attempts');
      } else {
        print('✅ [Main] Chat SignalR auto-connect completed');
        
        // Setup global chat listeners to receive messages even when not on chat screen
        final globalChatService = ref.read(globalChatServiceProvider);
        await globalChatService.setupListeners();
        print('✅ [Main] Global chat listeners setup completed');
      }
    } catch (e, stackTrace) {
      print('❌ [Main] Error initializing SignalR services: $e');
      print('Stack trace: $stackTrace');
      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _signalRInitialized = false;
          _initializeSignalR();
        }
      });
    }
  }

  void _setupAutoRefreshNotifications() {
    // Cancel existing timer if any
    _notificationRefreshTimer?.cancel();
    
    // Refresh notification list every 5 seconds as backup (SignalR should handle real-time)
    // This ensures we get notifications even if SignalR doesn't receive events
    _notificationRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        print('🔄 [Main] Auto-refreshing notification list (backup polling)...');
        final notificationNotifier = ref.read(notificationListProvider.notifier);
        notificationNotifier.refresh();
      } catch (e) {
        print('❌ [Main] Error auto-refreshing notifications: $e');
      }
    });
    
    print('✅ [Main] Auto-refresh notification timer started (every 5 seconds as backup)');
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
