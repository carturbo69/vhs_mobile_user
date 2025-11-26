import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final  asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(profileProvider.notifier).refresh();
            },
          )
        ],
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Lỗi: $e")),
        data: (profile) => _ProfileView(profile: profile),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildInfoCard("Tên tài khoản", profile.accountName),
        _buildInfoCard("Email", profile.email),
        // _buildInfoCard("Họ và tên", profile.fullName ?? "Chưa có"),
        // _buildInfoCard("Số điện thoại", profile.phoneNumber ?? "Chưa có"),
        // _buildInfoCard("Địa chỉ", profile.address ?? "Chưa có"),
        _buildInfoCard("Ngày tạo", profile.createdAt?.toLocal().toString() ?? "Không rõ"),
        const SizedBox(height: 30),
        _buildEditButton(context),
      ],
    );
  }

  Widget _buildHeader() {
    final imageUrl = profile.imageList.isNotEmpty ? profile.imageList.first : null;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imageUrl != null
              ? CachedNetworkImageProvider(imageUrl)
              : null,
          child: imageUrl == null
              ? const Icon(Icons.person, size: 48, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.fullName ?? profile.accountName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          profile.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text("Chỉnh sửa địa chỉ"),
      onPressed: () {
        context.push(Routes.addressList);
        // context.push(Routes.editProfile);
      },
    );
  }
}
