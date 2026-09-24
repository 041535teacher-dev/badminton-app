import 'package:flutter/material.dart';

void main() {
  runApp(const BadmintonTrackerApp());
}

class BadmintonTrackerApp extends StatelessWidget {
  const BadmintonTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'バドミントン失点分析',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const BadmintonTrackerScreen(),
    );
  }
}

enum LossArea { front, back }
enum LossCause { deep, front, miss }

extension LossAreaExtension on LossArea {
  String get label {
    switch (this) {
      case LossArea.front:
        return '前';
      case LossArea.back:
        return '後';
    }
  }
}

extension LossCauseExtension on LossCause {
  String get label {
    switch (this) {
      case LossCause.deep:
        return '奥へ追い込まれた';
      case LossCause.front:
        return '前へ出された';
      case LossCause.miss:
        return 'ミス（ネット、アウト、空振り、サーブミスなど）';
    }
  }
}

class LossRecord {
  final LossArea area;
  final LossCause cause;

  LossRecord({required this.area, required this.cause});
}

class BadmintonTrackerScreen extends StatefulWidget {
  const BadmintonTrackerScreen({super.key});

  @override
  State<BadmintonTrackerScreen> createState() => _BadmintonTrackerScreenState();
}

class _BadmintonTrackerScreenState extends State<BadmintonTrackerScreen> {
  LossArea _selectedArea = LossArea.front;
  LossCause _selectedCause = LossCause.deep;

  final List<LossRecord> _records = [];

  void _addRecord() {
    setState(() {
      _records.add(LossRecord(
        area: _selectedArea,
        cause: _selectedCause,
      ));
    });
  }

  void _undoLastRecord() {
    if (_records.isNotEmpty) {
      setState(() {
        _records.removeLast();
      });
    }
  }

  void _resetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('試合データのリセット'),
        content: const Text('集計されたデータをすべて削除してリセットしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _records.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  int get _countFrontArea => _records.where((r) => r.area == LossArea.front).length;
  int get _countBackArea => _records.where((r) => r.area == LossArea.back).length;

  int get _countCauseDeep => _records.where((r) => r.cause == LossCause.deep).length;
  int get _countCauseFront => _records.where((r) => r.cause == LossCause.front).length;
  int get _countCauseMiss => _records.where((r) => r.cause == LossCause.miss).length;

  @override
  Widget build(BuildContext context) {
    final total = _records.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('バドミントン失点分析'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '試合リセット',
            onPressed: _records.isEmpty ? null : _resetData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 集計カード
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '総失点数: $total',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('【失点エリア】', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('・ 前: $_countFrontArea 回'),
                              Text('・ 後: $_countBackArea 回'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('【崩れたきっかけ】', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('・ 奥へ追い込まれた: $_countCauseDeep 回'),
                              Text('・ 前へ出された: $_countCauseFront 回'),
                              Text('・ ミス: $_countCauseMiss 回'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 入力エリア①
            const Text('① 最後の失点エリア', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<LossArea>(
              segments: LossArea.values.map((area) {
                return ButtonSegment<LossArea>(
                  value: area,
                  label: Text(area.label, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              selected: {_selectedArea},
              onSelectionChanged: (Set<LossArea> newSelection) {
                setState(() {
                  _selectedArea = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            // 入力エリア②
            const Text('② 失点・崩れたきっかけ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: LossCause.values.map((cause) {
                final isSelected = _selectedCause == cause;
                return ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                    child: Text(
                      cause.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCause = cause;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 記録ボタン
            ElevatedButton.icon(
              onPressed: _addRecord,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('失点を記録', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // Undo ボタン
            OutlinedButton.icon(
              onPressed: _records.isEmpty ? null : _undoLastRecord,
              icon: const Icon(Icons.undo),
              label: const Text('1件取り消す'),
            ),
            const SizedBox(height: 20),

            // 記録履歴リスト
            if (_records.isNotEmpty) ...[
              const Text('【記録履歴（最新順）】', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[_records.length - 1 - index];
                  final itemNumber = _records.length - index;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text('$itemNumber', style: const TextStyle(fontSize: 12)),
                      ),
                      title: Text('エリア: ${record.area.label} / きっかけ: ${record.cause.label}'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
