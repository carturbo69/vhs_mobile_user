import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        backgroundColor: Colors.transparent,
        title: const Text(
          "Hồ sơ cá nhân",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            ),
          ),
        ],
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Lỗi: $e")),
        data: (profile) => _ProfileView(profile: profile, ref: ref),
      ),
    );
  }
}

class _ProfileView extends ConsumerWidget {
  final ProfileModel profile;

  const _ProfileView({required this.profile, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeHelper.isDarkMode(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context, ref),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "Thông tin cá nhân"),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                Icons.person_outline,
                "Tên tài khoản",
                profile.accountName,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                Icons.email_outlined,
                "Email",
                profile.email,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                Icons.badge_outlined,
                "Họ và tên",
                profile.fullName ?? "Chưa có",
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                Icons.phone_outlined,
                "Số điện thoại",
                profile.phoneNumber ?? "Chưa có",
                Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                Icons.location_on_outlined,
                "Địa chỉ",
                profile.address ?? "Chưa có",
                Colors.red,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                Icons.calendar_today_outlined,
                "Ngày tạo",
                profile.createdAt != null
                    ? "${profile.createdAt!.toLocal().day}/${profile.createdAt!.toLocal().month}/${profile.createdAt!.toLocal().year}"
                    : "Không rõ",
                Colors.teal,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Tùy chọn"),
              const SizedBox(height: 16),
              _buildOptionButton(
                context: context,
                icon: Icons.edit_outlined,
                label: "Chỉnh sửa hồ sơ",
                iconColor: Colors.blue,
                onPressed: () {
                  context.push(Routes.editProfile, extra: profile);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                context: context,
                icon: Icons.lock_outline,
                label: "Đổi mật khẩu",
                iconColor: Colors.orange,
                onPressed: () {
                  context.push(Routes.changePassword);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                context: context,
                icon: Icons.email_outlined,
                label: "Đổi email",
                iconColor: Colors.green,
                onPressed: () {
                  context.push(Routes.changeEmail, extra: profile);
                },
              ),
              const SizedBox(height: 24),
              _buildLogoutOptionButton(context, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final imageUrl = profile.imageList.isNotEmpty
        ? profile.imageList.first
        : null;
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
    final fullImageUrl = imageUrl != null && !imageUrl.startsWith('http')
        ? '$baseUrl$imageUrl'
        : imageUrl;

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
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.blue.shade600,
                          size: 22,
                        ),
                        onPressed: () => _showImagePicker(context, ref),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                profile.fullName ?? profile.accountName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
              if (fullImageUrl != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Xóa ảnh đại diện',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _deleteImage(context, ref),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final success = await ref
            .read(profileProvider.notifier)
            .uploadImage(file);

        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tải ảnh lên thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải ảnh lên thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteImage(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa ảnh đại diện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(profileProvider.notifier).deleteImage();

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xóa ảnh thành công')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa ảnh thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    final isEmpty = value == "Chưa có" || value == "Không rõ";
    final isDark = ThemeHelper.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeHelper.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getSecondaryTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isEmpty 
                          ? ThemeHelper.getTertiaryTextColor(context)
                          : ThemeHelper.getTextColor(context),
                      fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = ThemeHelper.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            ThemeHelper.getLightBlueBackgroundColor(context),
            ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.5),
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
              color: ThemeHelper.getPrimaryColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark 
                  ? Colors.blue.shade300
                  : Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print("🔍 [Profile] _buildOptionButton onTap called for: $label");
        }
        onPressed();
      },
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
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
                color: iconColor.withOpacity(ThemeHelper.isDarkMode(context) ? 0.2 : 0.1),
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
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ThemeHelper.getSecondaryIconColor(context),
              size: 24,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLogoutOptionButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        // Hiển thị dialog xác nhận
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Xác nhận đăng xuất",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(
                  "Đăng xuất",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          // Gọi logout
          await ref.read(authStateProvider.notifier).logout();

          // Navigate về login screen
          if (context.mounted) {
            context.go(Routes.login);
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.isDarkMode(context)
              ? Colors.red.shade900.withOpacity(0.3)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.isDarkMode(context)
                ? Colors.red.shade700.withOpacity(0.5)
                : Colors.red.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(ThemeHelper.isDarkMode(context) ? 0.2 : 0.1),
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Đăng xuất",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.red.shade300,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
