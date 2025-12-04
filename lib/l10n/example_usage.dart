import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/l10n/app_localizations.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

/// File này chứa các ví dụ về cách sử dụng hệ thống localization
/// Không được import vào production code, chỉ dùng để tham khảo

// ============================================================================
// Example 1: Sử dụng cơ bản với AppLocalizations
// ============================================================================
class BasicUsageExample extends StatelessWidget {
  const BasicUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('app_name')),
      ),
      body: Column(
        children: [
          Text(AppLocalizations.of(context).t('login')),
          Text(AppLocalizations.of(context).translate('register')),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 2: Sử dụng Extension (Khuyến nghị)
// ============================================================================
class ExtensionUsageExample extends StatelessWidget {
  const ExtensionUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_name')), // Ngắn gọn!
      ),
      body: Column(
        children: [
          Text(context.tr('login')),
          Text(context.loc.t('register')), // Cách khác
          
          // Trong button
          ElevatedButton(
            onPressed: () {},
            child: Text(context.tr('save')),
          ),
          
          // Trong TextField
          TextField(
            decoration: InputDecoration(
              labelText: context.tr('username_or_email'),
              hintText: context.tr('username_or_email'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 3: Toggle ngôn ngữ với ConsumerWidget
// ============================================================================
class LanguageToggleExample extends ConsumerWidget {
  const LanguageToggleExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
        actions: [
          // Language toggle button
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: context.tr('language'),
            onPressed: () async {
              await ref.read(localeProvider.notifier).toggleLocale();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isVietnamese 
                        ? 'Changed to English' 
                        : 'Đã chuyển sang Tiếng Việt'
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('language'),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              isVietnamese ? '🇻🇳 Tiếng Việt' : '🇬🇧 English',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
              child: Text(context.tr('language')),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 4: Set ngôn ngữ cụ thể
// ============================================================================
class SetSpecificLocaleExample extends ConsumerWidget {
  const SetSpecificLocaleExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('language')),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Text('🇻🇳', style: TextStyle(fontSize: 32)),
            title: const Text('Tiếng Việt'),
            trailing: currentLocale.languageCode == 'vi' 
              ? const Icon(Icons.check, color: Colors.green)
              : null,
            onTap: () {
              ref.read(localeProvider.notifier)
                  .setLocale(const Locale('vi', 'VN'));
            },
          ),
          ListTile(
            leading: const Text('🇬🇧', style: TextStyle(fontSize: 32)),
            title: const Text('English'),
            trailing: currentLocale.languageCode == 'en' 
              ? const Icon(Icons.check, color: Colors.green)
              : null,
            onTap: () {
              ref.read(localeProvider.notifier)
                  .setLocale(const Locale('en', 'US'));
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 5: Sử dụng trong Form Validation
// ============================================================================
class FormValidationExample extends ConsumerWidget {
  const FormValidationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('register'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Email field
              TextFormField(
                decoration: InputDecoration(
                  labelText: context.tr('username_or_email'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('field_required');
                  }
                  if (!value.contains('@')) {
                    return context.tr('invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('field_required');
                  }
                  if (value.length < 6) {
                    return context.tr('password_too_short');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('success')),
                      ),
                    );
                  }
                },
                child: Text(context.tr('register')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Example 6: Sử dụng trong Dialog
// ============================================================================
class DialogExample extends ConsumerWidget {
  const DialogExample({super.key});

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirm')),
        content: Text(context.tr('logout')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('success'))),
              );
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile'))),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showDialog(context),
          child: Text(context.tr('logout')),
        ),
      ),
    );
  }
}

// ============================================================================
// Example 7: Sử dụng với ListView/Menu
// ============================================================================
class MenuExample extends ConsumerWidget {
  const MenuExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      {'key': 'profile', 'icon': Icons.person},
      {'key': 'settings', 'icon': Icons.settings},
      {'key': 'reviews', 'icon': Icons.star},
      {'key': 'history', 'icon': Icons.history},
      {'key': 'logout', 'icon': Icons.exit_to_app},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('options'))),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData),
            title: Text(context.tr(item['key'] as String)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle tap
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
// Example 8: Conditional Text based on Locale
// ============================================================================
class ConditionalTextExample extends ConsumerWidget {
  const ConditionalTextExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('app_name'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sử dụng translation key
            Text(
              context.tr('welcome'),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            
            // Conditional text cho trường hợp đặc biệt
            Text(
              isVietnamese 
                ? 'Xin chào! Đây là text đặc biệt.'
                : 'Hello! This is special text.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Button with flag emoji
            ElevatedButton.icon(
              icon: Text(isVietnamese ? '🇻🇳' : '🇬🇧'),
              label: Text(
                isVietnamese 
                  ? 'Đổi sang tiếng Anh' 
                  : 'Switch to Vietnamese'
              ),
              onPressed: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
            ),
          ],
        ),
      ),
    );
  }
}

