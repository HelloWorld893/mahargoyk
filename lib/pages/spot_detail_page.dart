// lib/pages/spot_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/content_item.dart';
import '../widgets/header.dart'; // AppHeaderをインポート
import 'map_page.dart'; // MapPageをインポート

class SpotDetailPage extends StatefulWidget {
  final ContentItem spot;

  // use_super_parameters の修正
  const SpotDetailPage({super.key, required this.spot});

  @override
  // library_private_types_in_public_api の修正
  SpotDetailPageState createState() => SpotDetailPageState();
}

// library_private_types_in_public_api の修正
class SpotDetailPageState extends State<SpotDetailPage> {
  LatLng? _userLocation;
  String? _distanceText;
  final MapController _mapController = MapController();
  late LatLng spotLocation;

  @override
  void initState() {
    super.initState();
    spotLocation = LatLng(widget.spot.latitude, widget.spot.longitude);
    _loadData();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('位置情報サービスが無効です。');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('位置情報の権限が拒否されました。');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('位置情報の権限が永久に拒否されました。');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _loadData() async {
    try {
      final position = await _getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          const distance = Distance();
          final double distanceInMeters = distance(
            _userLocation!,
            LatLng(widget.spot.latitude, widget.spot.longitude),
          );
          if (distanceInMeters >= 1000) {
            final double distanceInKm = distanceInMeters / 1000;
            _distanceText = '${distanceInKm.toStringAsFixed(2)} km';
          } else {
            _distanceText = '${distanceInMeters.toStringAsFixed(0)} m';
          }
        });
      }
    } catch (e) {
      // avoid_print の修正
      debugPrint(e.toString());
    }
  }

  // マップ画面に遷移するメソッド
  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPage(initialSpot: widget.spot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 680,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(widget.spot.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 720,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.spot.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.spot.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            widget.spot.address,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.directions_walk, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            widget.spot.access,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            widget.spot.hours,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.monetization_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            widget.spot.price,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_distanceText != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'ここから約 $_distanceText です。',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          SizedBox(
                            width: 680,
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: spotLocation,
                                  initialZoom: 15.0,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                                    subdomains: const ['a', 'b', 'c', 'd'],
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: spotLocation,
                                        width: 80,
                                        height: 80,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.blue,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToMap, // ここを修正
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: const Text(
                            'マップを見る',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
