import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? controller;
  LatLng? picked;

  @override
  Widget build(BuildContext context) {
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
          context.tr('select_location'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.9909, 105.8053), // SG default
              zoom: 14,
            ),
            onMapCreated: (c) => controller = c,
            onTap: (pos) {
              setState(() {
                picked = pos;
              });
            },
            markers: picked == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("picked"),
                      position: picked!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          // Custom zoom controls
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ThemeHelper.getCardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.getShadowColor(context),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (controller != null) {
                              final currentZoom = await controller!.getZoomLevel();
                              controller!.animateCamera(
                                CameraUpdate.zoomTo(currentZoom + 1),
                              );
                            }
                          },
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: ThemeHelper.getSecondaryIconColor(context),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: ThemeHelper.getDividerColor(context),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (controller != null) {
                              final currentZoom = await controller!.getZoomLevel();
                              controller!.animateCamera(
                                CameraUpdate.zoomTo(currentZoom - 1),
                              );
                            }
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              size: 20,
                              color: ThemeHelper.getSecondaryIconColor(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardBackgroundColor(context),
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getShadowColor(context),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: picked == null
                      ? null
                      : () async {
                          if (!mounted) return;
                          
                          try {
                            final addressData = await _reverseGeocode(picked!);

                            // Trả về dữ liệu
                            if (mounted) {
                              final resultData = {
                                "lat": picked!.latitude,
                                "lng": picked!.longitude,
                                "provinceName": addressData["provinceName"] ?? "",
                                "districtName": addressData["districtName"] ?? "",
                                "wardName": addressData["wardName"] ?? "",
                                "streetAddress": addressData["streetAddress"] ?? "",
                                "address": addressData["fullAddress"] ?? "",
                              };
                              
                              print('🔍 [LocationPicker] Returning data: $resultData');
                              Navigator.pop(context, resultData);
                            }
                          } catch (e) {
                            print('❌ [LocationPicker] Error in reverse geocoding: $e');
                            
                            // Hiển thị lỗi
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('error_getting_address') ?? 'Không thể lấy địa chỉ. Vui lòng thử lại.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.check_circle_rounded, size: 24),
                  label: Text(
                    context.tr('select_location'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _reverseGeocode(LatLng pos) async {
    try {
      print('🔍 [LocationPicker] Reverse geocoding for: ${pos.latitude}, ${pos.longitude}');
      
      // Gọi placemarkFromCoordinates (không có localeIdentifier vì có thể không hỗ trợ)
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      print('🔍 [LocationPicker] Placemarks count: ${placemarks.length}');

      if (placemarks.isEmpty) {
        print('⚠️ [LocationPicker] No placemarks found');
        return {
          "provinceName": "",
          "districtName": "",
          "wardName": "",
          "streetAddress": "",
          "fullAddress": "${pos.latitude}, ${pos.longitude}",
        };
      }

      final p = placemarks.first;
      
      print('🔍 [LocationPicker] Placemark data:');
      print('  - name: ${p.name}');
      print('  - street: ${p.street}');
      print('  - thoroughfare: ${p.thoroughfare}');
      print('  - subThoroughfare: ${p.subThoroughfare}');
      print('  - locality: ${p.locality}');
      print('  - subLocality: ${p.subLocality}');
      print('  - administrativeArea: ${p.administrativeArea}');
      print('  - subAdministrativeArea: ${p.subAdministrativeArea}');
      print('  - country: ${p.country}');
      print('  - postalCode: ${p.postalCode}');
      print('  - isoCountryCode: ${p.isoCountryCode}');

      // Parse địa chỉ thành các thành phần
      // Với địa chỉ Việt Nam, cấu trúc có thể khác nhau tùy vào nguồn dữ liệu
      // Thử nhiều cách để lấy đúng thông tin
      
      String provinceName = "";
      String districtName = "";
      String wardName = "";
      String streetAddress = "";
      
      // Lấy Tỉnh/Thành phố
      provinceName = p.administrativeArea ?? "";
      if (provinceName.isEmpty && p.subAdministrativeArea != null) {
        // Đôi khi subAdministrativeArea chứa tên tỉnh
        final subAdmin = p.subAdministrativeArea!;
        if (subAdmin.contains("Province") || subAdmin.contains("City") || 
            subAdmin.contains("Tỉnh") || subAdmin.contains("Thành phố")) {
          provinceName = subAdmin;
        }
      }
      
      // Lấy Quận/Huyện
      districtName = p.subAdministrativeArea ?? p.locality ?? "";
      // Nếu đã dùng subAdministrativeArea cho province, thì dùng locality
      if (provinceName == p.subAdministrativeArea) {
        districtName = p.locality ?? "";
      }
      
      // Lấy Phường/Xã
      wardName = p.subLocality ?? "";
      
      // Lấy Đường/Số nhà - thử nhiều nguồn
      streetAddress = p.street ?? "";
      if (streetAddress.isEmpty) {
        streetAddress = p.thoroughfare ?? "";
      }
      if (streetAddress.isEmpty) {
        streetAddress = p.name ?? "";
      }
      // Kết hợp subThoroughfare và thoroughfare nếu có
      if (streetAddress.isEmpty) {
        final parts = [
          p.subThoroughfare,
          p.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).toList();
        streetAddress = parts.join(" ");
      }

      print('🔍 [LocationPicker] Parsed address:');
      print('  - provinceName: $provinceName');
      print('  - districtName: $districtName');
      print('  - wardName: $wardName');
      print('  - streetAddress: $streetAddress');

      // Tạo full address để hiển thị
      final fullAddressParts = [
        streetAddress,
        wardName,
        districtName,
        provinceName,
      ].where((e) => e.isNotEmpty);
      final fullAddress = fullAddressParts.join(", ");

      final result = {
        "provinceName": provinceName,
        "districtName": districtName,
        "wardName": wardName,
        "streetAddress": streetAddress,
        "fullAddress": fullAddress.isNotEmpty 
            ? fullAddress 
            : "${pos.latitude}, ${pos.longitude}",
      };
      
      print('🔍 [LocationPicker] Final result: $result');
      
      return result;
    } catch (e, stackTrace) {
      print('❌ [LocationPicker] Reverse geocoding error: $e');
      print('❌ [LocationPicker] Stack trace: $stackTrace');
      return {
        "provinceName": "",
        "districtName": "",
        "wardName": "",
        "streetAddress": "",
        "fullAddress": "${pos.latitude}, ${pos.longitude}",
      };
    }
  }
}
