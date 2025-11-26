import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';

import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(userAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa chỉ của tôi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(userAddressProvider.notifier).refresh(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addAddress),
        icon: const Icon(Icons.add_location_alt),
        label: const Text("Thêm địa chỉ"),
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Lỗi: $err")),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyAddress();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _AddressCard(address: list[i]),
          );
        },
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final UserAddressModel address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          address.fullAddress,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (address.recipientName != null)
              Text("Người nhận: ${address.recipientName!}"),
            if (address.recipientPhone != null)
              Text("SĐT: ${address.recipientPhone!}"),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: "edit",
              child: Text("Sửa"),
            ),
            const PopupMenuItem(
              value: "delete",
              child: Text("Xóa"),
            ),
          ],
          onSelected: (value) async {
            if (value == "edit") {
              context.push(Routes.addAddress, extra: address);
            } else {
              await ref
                  .read(userAddressProvider.notifier)
                  .remove(address.addressId);
            }
          },
        ),
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Bạn chưa có địa chỉ nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "Hãy thêm một địa chỉ mới",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.push(Routes.addAddress);
            },
            icon: const Icon(Icons.add_location_alt),
            label: const Text("Thêm địa chỉ đầu tiên"),
          )
        ],
      ),
    );
  }
}
