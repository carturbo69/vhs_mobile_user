import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(profileProvider.notifier).refresh();
            },
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(context, ref),
        const SizedBox(height: 20),
        _buildInfoCard("Tên tài khoản", profile.accountName),
        _buildInfoCard("Email", profile.email),
        _buildInfoCard("Họ và tên", profile.fullName ?? "Chưa có"),
        _buildInfoCard("Số điện thoại", profile.phoneNumber ?? "Chưa có"),
        _buildInfoCard("Địa chỉ", profile.address ?? "Chưa có"),
        _buildInfoCard(
          "Ngày tạo",
          profile.createdAt?.toLocal().toString() ?? "Không rõ",
        ),
        const SizedBox(height: 30),
        _buildEditButton(context),
        const SizedBox(height: 12),
        _buildChangePasswordButton(context),
        const SizedBox(height: 12),
        _buildChangeEmailButton(context),
        const SizedBox(height: 12),
        _buildManageAddressButton(context),
        const SizedBox(height: 12),
        _buildLogoutButton(context, ref),
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

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: fullImageUrl != null
                  ? CachedNetworkImageProvider(fullImageUrl)
                  : null,
              child: fullImageUrl == null
                  ? const Icon(Icons.person, size: 48, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showImagePicker(context, ref),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          profile.fullName ?? profile.accountName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          profile.email,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        if (fullImageUrl != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Xóa ảnh đại diện'),
            onPressed: () => _deleteImage(context, ref),
          ),
        ],
      ],
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

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text("Chỉnh sửa hồ sơ"),
      onPressed: () {
        context.push(Routes.editProfile, extra: profile);
      },
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.lock),
      label: const Text("Đổi mật khẩu"),
      onPressed: () {
        context.push(Routes.changePassword);
      },
    );
  }

  Widget _buildChangeEmailButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.email),
      label: const Text("Đổi email"),
      onPressed: () {
        context.push(Routes.changeEmail, extra: profile);
      },
    );
  }

  Widget _buildManageAddressButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.location_on),
      label: const Text("Quản lý địa chỉ"),
      onPressed: () {
        context.push(Routes.addressList, extra: profile);
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout_rounded),
      label: const Text("Đăng xuất"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
      onPressed: () async {
        // Hiển thị dialog xác nhận
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Xác nhận đăng xuất"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Đăng xuất"),
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
    );
  }
}
