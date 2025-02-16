import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IpMap extends StatelessWidget {
  final double lat;
  final double lng;

  const IpMap({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 11.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ip_tracker',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, lng),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
