import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/providers/theme_provider.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/l10n/app_localizations.dart';
import 'package:vhs_mobile_user/routing/routes.dart';

class ProfileSummaryScreen extends ConsumerWidget {
  const ProfileSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                ref.read(profileProvider.notifier).refresh();
              },
              tooltip: AppLocalizations.of(context).t('refresh'),
            ),
          ),
        ],
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text("${AppLocalizations.of(context).t('error')}: $e"),
        ),
        data: (profile) => _ProfileSummaryView(profile: profile, ref: ref),
      ),
    );
  }
}

class _ProfileSummaryView extends ConsumerWidget {
  final ProfileModel profile;
  final WidgetRef ref;

  const _ProfileSummaryView({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = profile.imageList.isNotEmpty
        ? profile.imageList.first
        : null;
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
    final fullImageUrl = imageUrl != null && !imageUrl.startsWith('http')
        ? '$baseUrl$imageUrl'
        : imageUrl;

    return Column(
      children: [
        // Header với gradient
        _buildHeader(context, fullImageUrl),
        // Content - scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle(AppLocalizations.of(context).t('options'), context),
                const SizedBox(height: 16),
                // 3 nút: Đánh giá, Chế độ sáng-tối, Tiếng anh - Tiếng việt
                _buildMenuButton(
                  context: context,
                  icon: Icons.star_outline,
                  label: AppLocalizations.of(context).t('reviews'),
                  iconColor: Colors.amber,
                  onPressed: () {
                    if (kDebugMode) {
                      print("🔍 [ProfileSummary] Navigating to review list: ${Routes.reviewList}");
                    }
                    context.push(Routes.reviewList);
                  },
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    final isDark = themeMode == ThemeMode.dark;
                    
                    return _buildMenuButton(
                      context: context,
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      label: isDark 
                        ? AppLocalizations.of(context).t('dark_mode')
                        : AppLocalizations.of(context).t('light_mode'),
                      iconColor: Colors.orange,
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final locale = ref.watch(localeProvider);
                    final isVietnamese = locale.languageCode == 'vi';
                    
                    return _buildMenuButton(
                      context: context,
                      icon: Icons.language_outlined,
                      // Hiển thị ngôn ngữ hiện tại đang dùng
                      label: isVietnamese 
                        ? "🇻🇳 Tiếng Việt"  // Đang dùng Tiếng Việt → Hiển thị Tiếng Việt
                        : "🇬🇧 English",  // Đang dùng English → Hiển thị English
                      iconColor: Colors.blue,
                      onPressed: () async {
                        await ref.read(localeProvider.notifier).toggleLocale();
                        
                        // Show snackbar để thông báo đã đổi ngôn ngữ
                        if (context.mounted) {
                          final newLocale = ref.read(localeProvider);
                          final message = newLocale.languageCode == 'vi'
                              ? "Đã chuyển sang Tiếng Việt"
                              : "Changed to English";
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuButton(
                  context: context,
                  icon: Icons.business_center_outlined,
                  label: AppLocalizations.of(context).t('provider_registration_guide') ?? 
                      'Hướng dẫn đăng ký nhà cung cấp',
                  iconColor: Colors.green,
                  onPressed: () {
                    context.push(Routes.providerRegistrationGuide);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String? fullImageUrl) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Avatar - có thể click
              InkWell(
                onTap: () {
                  context.push(Routes.profileDetail);
                },
                borderRadius: BorderRadius.circular(70),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: fullImageUrl != null
                        ? CachedNetworkImageProvider(fullImageUrl)
                        : null,
                    child: fullImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue.shade300,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tên - có thể click
              InkWell(
                onTap: () {
                  context.push(Routes.profileDetail);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.fullName ?? profile.accountName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Email với icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? [
                  Colors.blue.shade900.withOpacity(0.3),
                  Colors.blue.shade800.withOpacity(0.2),
                ]
              : [
                  Colors.blue.shade50,
                  Colors.blue.shade100.withOpacity(0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.blue.shade700.withOpacity(0.5)
              : Colors.blue.shade200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade400 : Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

