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
              target: LatLng(10.776889, 106.700806), // SG default
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
          // Center pin indicator
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 48,
                  color: ThemeHelper.getPrimaryColor(context),
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: ThemeHelper.getShadowColor(context),
                    ),
                  ],
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context),
                    shape: BoxShape.circle,
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
                          final addressData = await _reverseGeocode(picked!);

                          Navigator.pop(context, {
                            "lat": picked!.latitude,
                            "lng": picked!.longitude,
                            "provinceName": addressData["provinceName"] ?? "",
                            "districtName": addressData["districtName"] ?? "",
                            "wardName": addressData["wardName"] ?? "",
                            "streetAddress": addressData["streetAddress"] ?? "",
                            "address": addressData["fullAddress"] ?? "",
                          });
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
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final p = placemarks.first;

      // Parse địa chỉ thành các thành phần
      // Với địa chỉ Việt Nam:
      // - administrativeArea: Tỉnh/Thành phố
      // - subAdministrativeArea hoặc locality: Quận/Huyện
      // - subLocality: Phường/Xã
      // - street: Đường/Số nhà
      
      String provinceName = p.administrativeArea ?? "";
      String districtName = p.subAdministrativeArea ?? p.locality ?? "";
      String wardName = p.subLocality ?? "";
      String streetAddress = p.street ?? "";
      
      // Nếu không có street, thử dùng name hoặc thoroughfare
      if (streetAddress.isEmpty) {
        streetAddress = p.name ?? p.thoroughfare ?? "";
      }

      // Tạo full address để hiển thị
      final fullAddressParts = [
        streetAddress,
        wardName,
        districtName,
        provinceName,
      ].where((e) => e.isNotEmpty);
      final fullAddress = fullAddressParts.join(", ");

      return {
        "provinceName": provinceName,
        "districtName": districtName,
        "wardName": wardName,
        "streetAddress": streetAddress,
        "fullAddress": fullAddress.isNotEmpty 
            ? fullAddress 
            : "${pos.latitude}, ${pos.longitude}",
      };
    } catch (e) {
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
