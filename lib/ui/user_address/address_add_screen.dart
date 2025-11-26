import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_create_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _province = TextEditingController();
  final _district = TextEditingController();
  final _ward = TextEditingController();
  final _street = TextEditingController();
  final _recipientName = TextEditingController();
  final _recipientPhone = TextEditingController();

  double? lat;
  double? lng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm địa chỉ")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field("Tỉnh/Thành phố", _province),
          _field("Quận/Huyện", _district),
          _field("Phường/Xã", _ward),
          _field("Đường/Số nhà", _street),
          _field("Tên người nhận", _recipientName),
          _field("SĐT người nhận", _recipientPhone),
          const SizedBox(height: 8), 

          // Pick location
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("Chọn vị trí trên bản đồ"),
            onPressed: () async {
              final result = await context.push(Routes.locationPicker);

              if (result != null) {
                final data = result as Map<String, dynamic>;
                setState(() {
                  lat = data["lat"];
                  lng = data["lng"];
                  _street.text = data["address"];
                });
              }
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userAddressProvider.notifier).add(
                    UserAddressCreateModel(
                      provinceName: _province.text,
                      districtName: _district.text,
                      wardName: _ward.text,
                      streetAddress: _street.text,
                      recipientName: _recipientName.text,
                      recipientPhone: _recipientPhone.text,
                      latitude: lat,
                      longitude: lng,
                    ),
                  );

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Lưu địa chỉ"),
          ),
        ],
      ),
    );
  }

  Widget _field(String title, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
