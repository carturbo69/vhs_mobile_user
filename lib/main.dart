import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/routing/router.dart';

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

class MyApp extends ConsumerWidget {
  final VoidCallback resetProviders;
  const MyApp({super.key, required this.resetProviders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VHS Mobile User',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: router,
    );
  }
}
