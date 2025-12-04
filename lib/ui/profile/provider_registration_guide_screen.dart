import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

class ProviderRegistrationGuideScreen extends ConsumerWidget {
  const ProviderRegistrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final isDark = ThemeHelper.isDarkMode(context);
    final isVietnamese = ref.watch(localeProvider).languageCode == 'vi';

    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.blue.shade700,
                      Colors.blue.shade900,
                    ]
                  : [
                      Colors.blue.shade400,
                      Colors.blue.shade600,
                    ],
            ),
          ),
        ),
        title: Text(
          context.tr('provider_registration_guide') ?? 'Hướng dẫn đăng ký nhà cung cấp',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVietnamese
                              ? 'Hướng dẫn đăng ký nhà cung cấp'
                              : 'Provider Registration Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVietnamese
                              ? 'Hãy truy cập website để thực hiện các bước đơn giản để trở thành nhà cung cấp dịch vụ của chúng tôi'
                              : 'Please visit our website to complete the simple steps to become a provider of our services',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Simple steps
            _buildSimpleStep(
              context,
              isDark,
              isVietnamese,
              stepNumber: 1,
              title: isVietnamese ? 'Điền thông tin cơ bản' : 'Fill Basic Information',
              description: isVietnamese
                  ? 'Nhập tên nhà cung cấp, số điện thoại, mô tả dịch vụ và tải ảnh đại diện'
                  : 'Enter provider name, phone number, service description and upload profile image',
              icon: Icons.person,
            ),
            
            _buildSimpleStep(
              context,
              isDark,
              isVietnamese,
              stepNumber: 2,
              title: isVietnamese ? 'Chọn danh mục dịch vụ' : 'Select Service Categories',
              description: isVietnamese
                  ? 'Chọn danh mục dịch vụ bạn cung cấp và các dịch vụ cụ thể trong mỗi danh mục'
                  : 'Select service categories you provide and specific services in each category',
              icon: Icons.category,
            ),
            
            _buildSimpleStep(
              context,
              isDark,
              isVietnamese,
              stepNumber: 3,
              title: isVietnamese ? 'Tải giấy phép kinh doanh' : 'Upload Business License',
              description: isVietnamese
                  ? 'Tải lên ít nhất 1 hình ảnh giấy phép kinh doanh (có thể chọn nhiều ảnh)'
                  : 'Upload at least 1 business license image (you can select multiple images)',
              icon: Icons.upload_file,
            ),
            
            _buildSimpleStep(
              context,
              isDark,
              isVietnamese,
              stepNumber: 4,
              title: isVietnamese ? 'Đồng ý điều khoản' : 'Agree to Terms',
              description: isVietnamese
                  ? 'Đọc và đồng ý với điều khoản dịch vụ và chính sách bảo hiểm'
                  : 'Read and agree to terms of service and insurance policy',
              icon: Icons.check_circle,
            ),
            
            _buildSimpleStep(
              context,
              isDark,
              isVietnamese,
              stepNumber: 5,
              title: isVietnamese ? 'Gửi đăng ký' : 'Submit Registration',
              description: isVietnamese
                  ? 'Nhấn nút "Đăng ký nhà cung cấp" và chờ xét duyệt (1-3 ngày làm việc)'
                  : 'Click "Register Provider" button and wait for approval (1-3 business days)',
              icon: Icons.send,
              isLast: true,
            ),
            
            const SizedBox(height: 24),
            
            // Note section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.shade900.withOpacity(0.2)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVietnamese ? 'Lưu ý:' : 'Note:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isVietnamese
                              ? 'Sau khi đăng ký, bạn sẽ nhận email thông báo khi hồ sơ được duyệt.'
                              : 'After registration, you will receive an email notification when your application is approved.',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStep(
    BuildContext context,
    bool isDark,
    bool isVietnamese, {
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeHelper.getPrimaryColor(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getPrimaryColor(context)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: ThemeHelper.getPrimaryColor(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.getSecondaryTextColor(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Connector line
        if (!isLast) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 24),
              Container(
                width: 2,
                height: 24,
                decoration: BoxDecoration(
                  color: ThemeHelper.getDividerColor(context),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}