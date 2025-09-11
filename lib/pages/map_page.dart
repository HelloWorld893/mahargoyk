
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
  // ---- Map / Data ----
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  List<ContentItem> _spots = [];
  ContentItem? _selectedSpot;

  // ---- Routing / Navigation ----
  bool _isRouteVisible = false;
  List<LatLng> _routePoints = [];
  List<dynamic> _routeSteps = [];
  int _currentStepIndex = 0;
  final FlutterTts _tts = FlutterTts();
  StreamSubscription<Position>? _posSub;

  // ---- Filters ----
  bool _showFilters = false;
  final Map<String, bool> _genreFilters = {
    '観光': false,
    'グルメ': false,
    'ショッピング': false,
    'ホテル・旅館': false,
    'お土産': false,
    'イベント': false,
    'ライフスタイル': false,
  };
  final Map<String, bool> _areaFilters = {
    '三宮・元町': false,
    '北野・新神戸': false,
    'メリケンパーク・ハーバーランド': false,
    '六甲山・摩耶山': false,
    '有馬温泉': false,
    '灘・東灘': false,
    '兵庫・長田': false,
    '須磨・垂水': false,
    'ポートアイランド・神戸空港': false,
    '西神・北神': false,
  };

  List<ContentItem> get _filteredSpots {
    final gs = _genreFilters.entries.where((e) => e.value).map((e) => e.key).toList();
    final as = _areaFilters.entries.where((e) => e.value).map((e) => e.key).toList();
    return _spots.where((s) {
      final gOk = gs.isEmpty || gs.contains(s.genre);
      final aOk = as.isEmpty || as.contains(s.area);
      return gOk && aOk;
    }).toList();
  }

  // ---- UI ----
  bool _isZoomedIn = false;
  final int _selectedIndex = 4;


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

  @override
  void dispose() {
    _posSub?.cancel();
    if (!kIsWeb) _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    if (!kIsWeb) {
      await _tts.setLanguage('ja-JP');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
    }
  }

  void _startLocationUpdates() {
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((p) {
      if (!mounted) return;
      setState(() => _userLocation = LatLng(p.latitude, p.longitude));
      if (_isRouteVisible && _userLocation != null) {
        _mapController.move(_userLocation!, _mapController.camera.zoom);
        _mapController.rotate(-p.heading);
        _checkRouteProgress();
      }
    });
  }

  // ================= Data =================
  Future<void> _loadMapData() async {
    try {
      final pos = await _getCurrentLocation();
      final spots = await _fetchSpots();
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        _spots = spots;
      });
    } catch (e) {
      debugPrint('マップデータ読込エラー: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception('位置情報サービスが無効です。');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置情報の権限が拒否されました。');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置情報の権限が永久に拒否されました。');
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<ContentItem>> _fetchSpots() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('spots').get();
      return snap.docs.map((d) => ContentItem.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('スポット読込エラー: $e');
      return [];
    }
  }

  // ================= Routing =================
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
      final res = await http.get(url);
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final poly = PolylinePoints().decodePolyline(data['routes'][0]['geometry']);
          final steps = data['routes'][0]['legs'][0]['steps'];

          setState(() {
            _routePoints = poly.map((p) => LatLng(p.latitude, p.longitude)).toList();
            _isRouteVisible = true;
            _routeSteps = steps.map((s) => {...s, 'announced': false}).toList();
            _currentStepIndex = 0;
          });
          _mapController.move(_userLocation!, 16.0);
          _speak('ナビゲーションを開始します。');
        } else {
          setState(() => _isRouteVisible = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('経路の取得に失敗しました。ルートが見つかりません。')),
          );
        }
      } else {
        setState(() => _isRouteVisible = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('サーバーエラーにより経路の取得に失敗しました。')),
        );
      }
    } catch (e) {
      setState(() => _isRouteVisible = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('HTTPリクエストエラーが発生しました。')));
      }
    }
  }

  void _checkRouteProgress() {
    if (_userLocation == null ||
        _routePoints.isEmpty ||
        _currentStepIndex >= _routeSteps.length) return;

    final next = _routeSteps[_currentStepIndex];
    final stepLoc = LatLng(
      next['maneuver']['location'][1],
      next['maneuver']['location'][0],
    );

    final d = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      stepLoc.latitude,
      stepLoc.longitude,
    );

    // 到着判定
    if (_currentStepIndex == _routeSteps.length - 1 && d < 20) {
      _speak('目的地に到着しました。ナビゲーションを終了します。');
      _endNavigation();
      return;
    }

    // 手前案内（1回だけ）
    if (d < 50 && !_routeSteps[_currentStepIndex]['announced']) {
      final instruction = next['maneuver']['instruction'] ?? '次の案内なし';
      _speak(instruction);
      _routeSteps[_currentStepIndex]['announced'] = true;
    }

    // ステップ更新
    if (d < 5) {
      setState(() => _currentStepIndex++);
    }
  }

  Future<void> _speak(String text) async {
    if (!kIsWeb) {
      await _tts.stop();
      await _tts.speak(text);
    }
  }

  void _endNavigation() {
    if (!mounted) return;
    setState(() {
      _isRouteVisible = false;
      _routePoints = [];
      _routeSteps = [];
      _currentStepIndex = 0;
      _selectedSpot = null;
    });
    _speak('ナビゲーションを終了しました。');
  }


  Widget _buildFilterSection(String title, Map<String, bool> opts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opts.keys.map((k) {
            return FilterChip(
              label: Text(k),
              selected: opts[k]!,
              onSelected: (v) => setState(() => opts[k] = v),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _navigationUi() {
    if (!_isRouteVisible || _selectedSpot == null || _userLocation == null) {
      return const SizedBox.shrink();
    }

    final total = Geolocator.distanceBetween(
      _routePoints.first.latitude,
      _routePoints.first.longitude,
      _routePoints.last.latitude,
      _routePoints.last.longitude,
    );
    final completed = Geolocator.distanceBetween(
      _routePoints.first.latitude,
      _routePoints.first.longitude,
      _userLocation!.latitude,
      _userLocation!.longitude,
    );
    final progress = (completed / total).clamp(0.0, 1.0);

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
                  Row(children: [
                    const Icon(Icons.pin_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _selectedSpot!.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ]),
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
              const Divider(height: 24),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '目的地まで: ${(total - completed).clamp(0.0, total).toStringAsFixed(1)} m',
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
    const LatLng sannomiya = LatLng(34.6946, 135.1952);

    return Scaffold(
      appBar: const AppHeader(),
      body: Stack(
        children: [
          // --- Map ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: sannomiya,
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
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              if (_isRouteVisible && _routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: _routePoints, color: Colors.blue, strokeWidth: 5),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.navigation, color: Colors.red, size: 36),
                    ),
                  ..._filteredSpots.map((spot) => Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: 72,
                        height: 64,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSpot = spot;
                              _isRouteVisible = false;
                              _routePoints = [];
                            });
                            _mapController.move(LatLng(spot.latitude, spot.longitude), 15.0);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_pin, color: Colors.blue, size: 32),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  spot.title,
                                  maxLines: 1, // ← オーバーフロー対策
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // --- Filter Button ---
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'filterButton',
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: Icon(_showFilters ? Icons.close : Icons.tune),
              label: Text(_showFilters ? '閉じる' : 'フィルター'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
          ),

          // --- Filter Panel ---
          Positioned(
            top: 80,
            left: 12,
            right: 12,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !_showFilters
                  ? const SizedBox.shrink()
                  : Card(
                      elevation: 6,
                      color: Colors.purple[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection('ジャンル', _genreFilters),
                            _buildFilterSection('エリア', _areaFilters),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(() {
                                  _genreFilters.updateAll((key, value) => false);
                                  _areaFilters.updateAll((key, value) => false);
                                }),
                                child: const Text('クリア'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // --- Spot mini card with route button ---
          if (_selectedSpot != null && !_isRouteVisible)
            Positioned(
              right: 16,
              top: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedSpot!.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _selectedSpot = null;
                              _isRouteVisible = false;
                              _routePoints = [];
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.network(
                          _selectedSpot!.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SpotDetailPage(spot: _selectedSpot!),
                                  ),
                                );
                              },
                              child: const Text('詳細を見る'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton.small(
                            heroTag: 'routeButton',
                            backgroundColor: Colors.white,
                            onPressed: _toggleRoute,
                            child: const Icon(Icons.directions, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // --- Navigation progress card ---
          _navigationUi(),

          // --- My location button ---
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'userLocationButton',
              onPressed: () {
                setState(() => _isZoomedIn = !_isZoomedIn);
                if (_isZoomedIn && _userLocation != null) {
                  _mapController.move(_userLocation!, 15.0);
                } else {
                  _mapController.move(sannomiya, 15.0);
                }
              },
              backgroundColor: _isZoomedIn ? Colors.blue[700] : Colors.white,
              child: Icon(Icons.my_location,
                  color: _isZoomedIn ? Colors.white : Colors.blue),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: _selectedIndex),
    );
  }
}
