import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      appBar: AppBar(title: const Text("Chọn vị trí")),

      body: GoogleMap(
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
            : {Marker(markerId: const MarkerId("picked"), position: picked!)},
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: picked == null
            ? null
            : () async {
                final address = await _reverseGeocode(picked!);

                Navigator.pop(context, {
                  "lat": picked!.latitude,
                  "lng": picked!.longitude,
                  "address": address,
                });
              },
        label: const Text("Chọn vị trí"),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Future<String> _reverseGeocode(LatLng pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final p = placemarks.first;

      return [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e!.isNotEmpty).join(", ");
    } catch (e) {
      return "${pos.latitude}, ${pos.longitude}";
    }
  }
}
