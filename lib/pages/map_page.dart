// lib/pages/map_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/content_item.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/header.dart';
import 'spot_detail_page.dart';

class MapPage extends StatefulWidget {
  final ContentItem? initialSpot;

  const MapPage({super.key, this.initialSpot});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  List<ContentItem> _spots = [];
  ContentItem? _selectedSpot;
  bool _isRouteVisible = false;
  List<LatLng> _routePoints = [];
  bool _isZoomedIn = false;
  final int _selectedIndex = 2;
  StreamSubscription<Position>? _positionSubscription;
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> _routeSteps = [];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();

    if (widget.initialSpot != null) {
      _selectedSpot = widget.initialSpot;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(widget.initialSpot!.latitude, widget.initialSpot!.longitude),
          15.0,
        );
      });
    }

    _loadMapData();
    _startLocationUpdates();
  }

  Future<void> _initTts() async {
    if (!kIsWeb) {
      await flutterTts.setLanguage('ja-JP');
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
    }
  }

  void _startLocationUpdates() {
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _userLocation = LatLng(position.latitude, position.longitude);
            });
            if (_isRouteVisible) {
              _mapController.move(_userLocation!, _mapController.camera.zoom);
              _mapController.rotate(-position.heading);
              _checkRouteProgress();
            }
          }
        });
  }

  void _checkRouteProgress() {
    if (_userLocation == null ||
        _routePoints.isEmpty ||
        _currentStepIndex >= _routeSteps.length) {
      return;
    }

    final nextStep = _routeSteps[_currentStepIndex];
    final stepLocation = LatLng(
      nextStep['maneuver']['location'][1],
      nextStep['maneuver']['location'][0],
    );

    final distanceToNextStep = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      stepLocation.latitude,
      stepLocation.longitude,
    );

    if (_currentStepIndex == _routeSteps.length - 1 &&
        distanceToNextStep < 20) {
      _speak("目的地に到着しました。ナビゲーションを終了します。");
      _endNavigation();
      return;
    }

    if (distanceToNextStep < 50 &&
        !_routeSteps[_currentStepIndex]['announced']) {
      final instruction = nextStep['maneuver']['instruction'] ?? '次の案内なし';
      _speak(instruction);
      _routeSteps[_currentStepIndex]['announced'] = true;
    }

    if (distanceToNextStep < 5) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  Future<void> _speak(String text) async {
    if (!kIsWeb) {
      await flutterTts.stop();
      await flutterTts.speak(text);
    }
  }

  void _endNavigation() {
    if (mounted) {
      setState(() {
        _isRouteVisible = false;
        _routePoints = [];
        _routeSteps = [];
        _currentStepIndex = 0;
        _selectedSpot = null;
      });
      _speak("ナビゲーションを終了しました。");
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    if (!kIsWeb) {
      flutterTts.stop();
    }
    super.dispose();
  }

  Future<void> _loadMapData() async {
    try {
      final position = await _getCurrentLocation();
      final spots = await _fetchSpots();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _spots = spots;
        });
      }
    } catch (e) {
      debugPrint('マップデータの読み込み中にエラーが発生しました: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置情報サービスが無効です。');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置情報の権限が拒否されました。');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置情報の権限が永久に拒否されました。');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<ContentItem>> _fetchSpots() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('spots')
          .get();
      return querySnapshot.docs
          .map((doc) => ContentItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('スポットの読み込み中にエラーが発生しました: $e');
      return [];
    }
  }

  void _toggleRoute() async {
    if (_userLocation == null || _selectedSpot == null) return;

    if (_isRouteVisible) {
      _endNavigation();
      return;
    }

    final start = '${_userLocation!.longitude},${_userLocation!.latitude}';
    final end = '${_selectedSpot!.longitude},${_selectedSpot!.latitude}';
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&steps=true',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return; // mounted チェックを追加

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final polyline = PolylinePoints().decodePolyline(
            data['routes'][0]['geometry'],
          );
          final legs = data['routes'][0]['legs'];
          final steps = legs[0]['steps'];

          setState(() {
            _routePoints = polyline
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
            _isRouteVisible = true;
            _routeSteps = steps
                .map((step) => {...step, 'announced': false})
                .toList();
            _currentStepIndex = 0;
          });
          _mapController.move(_userLocation!, 16.0);
          _speak("ナビゲーションを開始します。");
        } else {
          setState(() => _isRouteVisible = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('経路の取得に失敗しました。目的地までのルートが見つかりません。')),
          );
        }
      } else {
        setState(() => _isRouteVisible = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('経路の取得に失敗しました。サーバーエラーです。')),
        );
      }
    } catch (e) {
      setState(() => _isRouteVisible = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('HTTPリクエストエラーが発生しました。')));
      }
    }
  }

  void _toggleUserLocation() {
    setState(() {
      _isZoomedIn = !_isZoomedIn;
    });

    if (_isZoomedIn && _userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      _mapController.move(const LatLng(34.6946, 135.1952), 15.0);
    }
  }

  Widget _navigationUi() {
    if (!_isRouteVisible || _selectedSpot == null || _userLocation == null) {
      return const SizedBox.shrink();
    }

    final totalDistance = Geolocator.distanceBetween(
      _routePoints.first.latitude,
      _routePoints.first.longitude,
      _routePoints.last.latitude,
      _routePoints.last.longitude,
    );

    double completedDistance = 0;
    if (_currentStepIndex < _routeSteps.length) {
      completedDistance = Geolocator.distanceBetween(
        _routePoints.first.latitude,
        _routePoints.first.longitude,
        _userLocation!.latitude,
        _userLocation!.longitude,
      );
    }

    final progress = (completedDistance / totalDistance).clamp(0.0, 1.0);

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _selectedSpot!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: _endNavigation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('終了'),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '目的地まで: ${(totalDistance - completedDistance).clamp(0.0, totalDistance).toStringAsFixed(1)} m',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const LatLng sannomiyaStation = LatLng(34.6946, 135.1952);

    return Scaffold(
      appBar: const AppHeader(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: sannomiyaStation,
              initialZoom: 15.0,
              onTap: (_, __) {
                setState(() {
                  _selectedSpot = null;
                  _isRouteVisible = false;
                  _routePoints = [];
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),
              if (_isRouteVisible && _routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 80,
                      height: 80,
                      child: Transform.rotate(
                        angle:
                            -(_mapController.camera.rotation * (3.14159 / 180)),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ..._spots.map(
                    (spot) => Marker(
                      point: LatLng(spot.latitude, spot.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSpot = spot;
                            _isRouteVisible = false;
                            _routePoints = [];
                          });
                          _mapController.move(
                            LatLng(spot.latitude, spot.longitude),
                            15.0,
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 40,
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                spot.title,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
          if (_selectedSpot != null && !_isRouteVisible)
            Positioned(
              right: 16,
              top: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedSpot!.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedSpot = null;
                                _isRouteVisible = false;
                                _routePoints = [];
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.network(
                          _selectedSpot!.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder:
                              (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedSpot!.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SpotDetailPage(spot: _selectedSpot!),
                                  ),
                                );
                              },
                              child: const Text('詳細を見る'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton.small(
                            heroTag: "routeButton",
                            onPressed: _toggleRoute,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.directions,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          _navigationUi(),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "userLocationButton",
              onPressed: _toggleUserLocation,
              backgroundColor: _isZoomedIn ? Colors.blue[700] : Colors.white,
              child: Icon(
                Icons.my_location,
                color: _isZoomedIn ? Colors.white : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}
