import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_create_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_update_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

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
  
  // Static variable để lưu dữ liệu tạm thời - không bị mất khi widget recreate
  static Map<String, dynamic>? _staticPendingLocationData;

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
    
    // Luôn kiểm tra và load lại dữ liệu location từ static variable nếu có
    // Điều này đảm bảo dữ liệu được load khi widget được recreate sau khi quay lại từ location picker
    if (_staticPendingLocationData != null && mounted) {
      // Đợi một frame để đảm bảo widget đã được rebuild hoàn toàn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _staticPendingLocationData != null) {
          print('🔄 [AddAddress] Applying static pending location data in didChangeDependencies');
          _applyLocationData(_staticPendingLocationData!);
          _staticPendingLocationData = null; // Clear sau khi apply
        }
      });
    }
  }
  
  void _applyLocationData(Map<String, dynamic> data) {
    final latValue = data["lat"];
    final lngValue = data["lng"];
    
    setState(() {
      lat = latValue is double ? latValue : (latValue is num ? latValue.toDouble() : null);
      lng = lngValue is double ? lngValue : (lngValue is num ? lngValue.toDouble() : null);
      
      // Cập nhật vào TextEditingController
      _province.text = (data["provinceName"]?.toString() ?? "").trim();
      _district.text = (data["districtName"]?.toString() ?? "").trim();
      _ward.text = (data["wardName"]?.toString() ?? "").trim();
      _street.text = (data["streetAddress"]?.toString() ?? "").trim();
    });
    
    print('✅ [AddAddress] Applied location data:');
    print('  - lat: $lat, lng: $lng');
    print('  - province: ${_province.text}');
    print('  - district: ${_district.text}');
    print('  - ward: ${_ward.text}');
    print('  - street: ${_street.text}');
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
    // Watch locale để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    
    // Check và apply pending location data từ static variable nếu có (sau khi widget được rebuild)
    if (_staticPendingLocationData != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _staticPendingLocationData != null) {
          print('🔄 [AddAddress] Applying static pending location data in build method');
          _applyLocationData(_staticPendingLocationData!);
          _staticPendingLocationData = null; // Clear sau khi apply
        }
      });
    }
    
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
          isEditMode ? context.tr('edit_address') : context.tr('add_address'),
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
          // Pick location button - Đặt lên đầu
          Card(
            elevation: 2,
            shadowColor: ThemeHelper.getShadowColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                print('🔍 [AddAddress] Opening location picker...');
                
                final result = await context.push(Routes.locationPicker);
                
                print('🔍 [AddAddress] Location picker returned: $result');
                print('🔍 [AddAddress] Result type: ${result.runtimeType}');

                // Xử lý dữ liệu
                if (result != null && result is Map) {
                  final data = Map<String, dynamic>.from(result);
                  print('🔍 [AddAddress] Received location data: $data');
                  
                  // Lưu dữ liệu vào static variable để không bị mất khi widget recreate
                  _staticPendingLocationData = data;
                  print('💾 [AddAddress] Saved location data to static variable');
                  
                  // Sử dụng addPostFrameCallback để apply dữ liệu sau khi widget được rebuild
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _staticPendingLocationData != null) {
                      print('🔄 [AddAddress] Applying location data via postFrameCallback');
                      _applyLocationData(_staticPendingLocationData!);
                      _staticPendingLocationData = null; // Clear sau khi apply
                    } else {
                      print('⚠️ [AddAddress] Widget not mounted in postFrameCallback, will retry in build/didChangeDependencies');
                    }
                  });
                  
                  // Trigger rebuild để đảm bảo build method được gọi và postFrameCallback được thực thi
                  if (mounted) {
                    setState(() {
                      // Empty setState để trigger rebuild
                    });
                  } else {
                    print('⚠️ [AddAddress] Widget not mounted, data saved to static variable - will be applied when widget rebuilds');
                  }
                } else {
                  print('⚠️ [AddAddress] No location data received (result is null or not a Map)');
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
                            context.tr('select_location_on_map'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('select_location_to_auto_fill'),
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
          
          const SizedBox(height: 24),
          
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
                  context.tr('address_information'),
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
          _field(context.tr('province_city'), _province, Icons.location_city),
          _field(context.tr('district'), _district, Icons.map),
          _field(context.tr('ward'), _ward, Icons.home),
          _field(context.tr('street_house_number'), _street, Icons.signpost),
          
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
                  context.tr('recipient_information'),
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
          _field(context.tr('recipient_name'), _recipientName, Icons.person_outline),
          _field(context.tr('recipient_phone'), _recipientPhone, Icons.phone),

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
                  _editingAddress != null ? context.tr('update_address') : context.tr('save_address'),
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
