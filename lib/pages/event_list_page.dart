// lib/pages/event_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/content_item.dart';
import 'spot_detail_page.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/header.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // ユーザーが選択中のフィルター値
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedArea;

  // 実際に絞り込みに使われるフィルター値
  DateTime? _appliedStartDate;
  DateTime? _appliedEndDate;
  String? _appliedArea;

  final List<String> _areaOptions = const [
    'すべてのエリア',
    '北区',
    'ウォーターフロント',
    '六甲アイランド',
    '花隈',
    '新開地',
    '三宮・元町',
    '北野・新神戸',
    'メリケンパーク・ハーバーランド',
    '六甲山・摩耶山',
    '有馬温泉',
    '灘・東灘',
    '兵庫・長田',
    '須磨・垂水',
    'ポートアイランド・神戸空港',
    '西神・北神',
  ];

  @override
  void initState() {
    super.initState();
    _selectedArea = _areaOptions.first;
    // 初期状態で一度フィルターを適用しておく
    _applyFilters();
  }

  // 日付選択のUIを表示する関数
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _selectedStartDate : _selectedEndDate) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  // 「絞り込む」ボタンが押された時の処理
  void _applyFilters() {
    setState(() {
      _appliedStartDate = _selectedStartDate;
      _appliedEndDate = _selectedEndDate;
      _appliedArea = _selectedArea == 'すべてのエリア' ? null : _selectedArea;
    });
  }

  // イベントの開催状況（開催中、開催前、終了）を返す関数
  String _getEventStatus(ContentItem item) {
    final now = DateTime.now();
    final startDate = item.startDate?.toDate();
    final endDate = item.endDate?.toDate();

    if (startDate == null || endDate == null) return '';
    if (now.isAfter(startDate) && now.isBefore(endDate)) return '開催中';
    if (now.isBefore(startDate)) return '開催前';
    return '終了';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        // 画面全体をColumnで構成
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- フィルターUI部分 ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'イベント一覧',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                // 期間フィルター
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedStartDate == null
                                ? '開始日'
                                : DateFormat(
                                    'yyyy/MM/dd',
                                  ).format(_selectedStartDate!),
                            style: TextStyle(
                              color: _selectedStartDate == null
                                  ? Colors.grey.shade700
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('〜'),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedEndDate == null
                                ? '終了日'
                                : DateFormat(
                                    'yyyy/MM/dd',
                                  ).format(_selectedEndDate!),
                            style: TextStyle(
                              color: _selectedEndDate == null
                                  ? Colors.grey.shade700
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // エリアフィルター
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedArea,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) =>
                          setState(() => _selectedArea = newValue),
                      items: _areaOptions
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 絞り込みボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'この条件で絞り込む',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
              ],
            ),
          ),

          // --- イベント一覧表示部分 ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('イベント情報がありません。'));
                }

                final allDocs = snapshot.data!.docs;
                // フィルターロジック
                final filteredDocs = allDocs.where((doc) {
                  final item = ContentItem.fromFirestore(doc);
                  final matchesArea =
                      _appliedArea == null || item.area == _appliedArea;
                  final eventStartDate = item.startDate?.toDate();
                  final eventEndDate = item.endDate?.toDate();
                  bool matchesDate = true;
                  if (_appliedStartDate != null && eventEndDate != null) {
                    matchesDate =
                        matchesDate &&
                        !eventEndDate.isBefore(_appliedStartDate!);
                  }
                  if (_appliedEndDate != null && eventStartDate != null) {
                    matchesDate =
                        matchesDate &&
                        !eventStartDate.isAfter(
                          _appliedEndDate!.add(const Duration(days: 1)),
                        );
                  }
                  return matchesArea && matchesDate;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '${filteredDocs.length}件 / ${allDocs.length}件中',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filteredDocs.isEmpty
                          ? const Center(child: Text('条件に合うイベントが見つかりませんでした。'))
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final item = ContentItem.fromFirestore(
                                  filteredDocs[index],
                                );
                                final status = _getEventStatus(item);
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SpotDetailPage(spot: item),
                                    ),
                                  ),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (status.isNotEmpty) ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: status == '開催中'
                                                          ? Colors.redAccent
                                                          : (status == '開催前'
                                                                ? Colors
                                                                      .blueAccent
                                                                : Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      status,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                ],
                                                Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const Spacer(),
                                                if (item.startDate != null)
                                                  Text(
                                                    "${DateFormat('MM/dd').format(item.startDate!.toDate())} - ${DateFormat('MM/dd').format(item.endDate!.toDate())}",
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                if (item.area.isNotEmpty)
                                                  Text(
                                                    "エリア: ${item.area}",
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}
