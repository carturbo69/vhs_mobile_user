import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_create_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_update_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

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
  UserAddressModel? _editingAddress;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Lấy địa chỉ từ extra nếu có (edit mode)
      final extra = GoRouterState.of(context).extra;
      if (extra is UserAddressModel) {
        _editingAddress = extra;
        _loadAddressData(extra);
      }
      _isInitialized = true;
    }
  }

  void _loadAddressData(UserAddressModel address) {
    _province.text = address.provinceName ?? '';
    _district.text = address.districtName ?? '';
    _ward.text = address.wardName ?? '';
    _street.text = address.streetAddress ?? '';
    _recipientName.text = address.recipientName ?? '';
    _recipientPhone.text = address.recipientPhone ?? '';
    lat = address.latitude;
    lng = address.longitude;
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _editingAddress != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
        title: Text(
          isEditMode ? "Sửa địa chỉ" : "Thêm địa chỉ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Thông tin địa chỉ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeHelper.getLightBlueBackgroundColor(context),
                  ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: ThemeHelper.getPrimaryDarkColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin địa chỉ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field("Tỉnh/Thành phố", _province, Icons.location_city),
          _field("Quận/Huyện", _district, Icons.map),
          _field("Phường/Xã", _ward, Icons.home),
          _field("Đường/Số nhà", _street, Icons.signpost),
          
          const SizedBox(height: 24),
          
          // Section: Thông tin người nhận
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeHelper.getLightBlueBackgroundColor(context),
                  ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: ThemeHelper.getPrimaryDarkColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin người đặt lịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field("Tên người đặt", _recipientName, Icons.person_outline),
          _field("Số điện thoại người đặt", _recipientPhone, Icons.phone),
          
          const SizedBox(height: 24),
          
          // Pick location button
          Card(
            elevation: 2,
            shadowColor: ThemeHelper.getShadowColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                final result = await context.push(Routes.locationPicker);

                if (result != null) {
                  final data = result as Map<String, dynamic>;
                  setState(() {
                    lat = data["lat"] as double?;
                    lng = data["lng"] as double?;
                    // Điền vào tất cả các trường
                    _province.text = data["provinceName"] as String? ?? "";
                    _district.text = data["districtName"] as String? ?? "";
                    _ward.text = data["wardName"] as String? ?? "";
                    _street.text = data["streetAddress"] as String? ?? "";
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.map,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chọn vị trí trên bản đồ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Chọn vị trí để tự động điền địa chỉ",
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeHelper.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
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
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (_editingAddress != null) {
                // Edit mode
                await ref.read(userAddressProvider.notifier).edit(
                      _editingAddress!.addressId,
                      UserAddressUpdateModel(
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
              } else {
                // Add mode
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
              }

              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeHelper.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _editingAddress != null 
                      ? Icons.save_rounded 
                      : Icons.add_location_alt_rounded,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _editingAddress != null ? "Cập nhật địa chỉ" : "Lưu địa chỉ",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _field(String title, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeHelper.getLightBlueBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ThemeHelper.getPrimaryColor(context),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeHelper.getBorderColor(context),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeHelper.getBorderColor(context),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeHelper.getPrimaryColor(context),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: ThemeHelper.getInputBackgroundColor(context),
          labelStyle: TextStyle(
            color: ThemeHelper.getSecondaryTextColor(context),
          ),
          hintStyle: TextStyle(
            color: ThemeHelper.getSecondaryTextColor(context),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
