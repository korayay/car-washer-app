import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'dart:math';

class WasherAnalysisScreen extends StatefulWidget {
  const WasherAnalysisScreen({super.key});

  @override
  State<WasherAnalysisScreen> createState() => _WasherAnalysisScreenState();
}

class _WasherAnalysisScreenState extends State<WasherAnalysisScreen> {
  // Sadece bu değerlerden biri olabilir:
  static const List<String> _rangeOptions = ['Bu Hafta', 'Bu Ay', 'Son 3 Ay', 'Özel Aralık'];
  static const List<String> _packageOptions = ['Tümü', 'Dry Clean', 'Green', 'Shine'];
  String? _selectedRange;
  String _selectedPackage = 'Tümü';
  String _selectedMetric = 'Yıkama';
  DateTimeRange? _customRange;

  // Örnek veri
  final List<int> _washCounts = [2, 3, 1, 4, 5, 2, 3, 6, 4, 2, 3, 5, 7, 6, 4, 3, 2, 5, 6, 4, 3, 2, 1, 3, 4, 5, 6, 7, 5, 4];
  final List<int> _earnings = [50, 80, 30, 120, 90, 60, 100, 140, 110, 70, 60, 130, 150, 120, 100, 90, 60, 110, 140, 100, 80, 60, 40, 90, 100, 120, 130, 150, 120, 110];
  final List<String> _days = List.generate(30, (i) => (i + 1).toString());

  @override
  Widget build(BuildContext context) {
    // Her build'te null olma ihtimaline karşı koruma
    if (_selectedRange == null) _selectedRange = 'Bu Ay';
    final List<int> chartData = _selectedMetric == 'Yıkama' ? _washCounts : _earnings;
    final String chartUnit = _selectedMetric == 'Yıkama' ? 'adet' : '₺';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('İş Analizleri'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Genel Performans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Son 30 gün ve toplam istatistikler',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _AnalysisCard(
                  icon: Icons.local_car_wash,
                  title: 'Toplam Yıkama',
                  value: '42',
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                _AnalysisCard(
                  icon: Icons.attach_money,
                  title: 'Bu Ayki Kazanç',
                  value: '₺2.350',
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _AnalysisCard(
                  icon: Icons.star,
                  title: 'Ortalama Puan',
                  value: '4.8',
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _AnalysisCard(
                  icon: Icons.timer,
                  title: 'Ortalama Süre',
                  value: '38 dk',
                  color: AppTheme.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Filtreler
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _rangeOptions.contains(_selectedRange) && _selectedRange != null ? _selectedRange : 'Bu Ay',
                    decoration: const InputDecoration(
                      labelText: 'Tarih Aralığı',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _rangeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      if (v == 'Özel Aralık') {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          initialDateRange: _customRange,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedRange = v;
                            _customRange = picked;
                          });
                        }
                        // Eğer kullanıcı iptal ederse, hiçbir şey yapma (seçili değer değişmesin)
                      } else {
                        setState(() {
                          _selectedRange = v;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPackage,
                    decoration: const InputDecoration(
                      labelText: 'Paket Tipi',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _packageOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedPackage = v!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Kazanç/Yıkama toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButtons(
                  isSelected: [
                    _selectedMetric == 'Yıkama',
                    _selectedMetric == 'Kazanç',
                  ],
                  onPressed: (i) {
                    setState(() => _selectedMetric = i == 0 ? 'Yıkama' : 'Kazanç');
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: AppTheme.primaryColor,
                  color: AppTheme.primaryColor,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Yıkama'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Kazanç'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Çizgi grafik
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _LineChart(
                values: chartData,
                labels: _days,
                color: AppTheme.primaryColor,
                unit: chartUnit,
              ),
            ),
            const SizedBox(height: 32),
            // Pie chart
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  // Demo veri: Dry Clean, Green, Shine
                  final allValues = [18, 14, 10];
                  final allLabels = ['Dry Clean', 'Green', 'Shine'];
                  final allColors = [AppTheme.primaryColor, AppTheme.greenPrimary, AppTheme.accentColor];
                  if (_selectedPackage == 'Tümü') {
                    return _PieChart(
                      values: allValues,
                      labels: allLabels,
                      colors: allColors,
                    );
                  } else {
                    int idx = allLabels.indexOf(_selectedPackage);
                    int selected = idx >= 0 ? allValues[idx] : 0;
                    int other = allValues.asMap().entries.where((e) => e.key != idx).map((e) => e.value).fold(0, (a, b) => a + b);
                    return _PieChart(
                      values: [selected, other],
                      labels: [_selectedPackage, 'Diğer'],
                      colors: [allColors[idx >= 0 ? idx : 0], AppTheme.grey300],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            // Diğer özet kartlar
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('En Çok Yıkama Yapılan Gün: 12 Haziran', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('En Yüksek Kazançlı Gün: 7 Haziran', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('En Çok Tercih Edilen Paket: Premium', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _AnalysisCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final Color color;
  final String unit;

  const _LineChart({
    required this.values,
    required this.labels,
    required this.color,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final chartHeight = 120.0;
    final chartWidth = MediaQuery.of(context).size.width - 72; // padding + card
    final pointCount = values.length;
    final dx = chartWidth / (pointCount - 1);

    return Stack(
      children: [
        // Y ekseni değerleri
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$maxValue $unit', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor)),
              Text('${((maxValue + minValue) ~/ 2)} $unit', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor)),
              Text('$minValue $unit', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: CustomPaint(
            size: Size(chartWidth - 32, chartHeight),
            painter: _LineChartPainter(values, color, maxValue, minValue),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> values;
  final Color color;
  final int maxValue;
  final int minValue;

  _LineChartPainter(this.values, this.color, this.maxValue, this.minValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / (maxValue - minValue + 1e-5)) * size.height;
      points.add(Offset(x, y));
    }

    // Fill area under line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    // Draw points
    for (final p in points) {
      canvas.drawCircle(p, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChart extends StatefulWidget {
  final List<int> values;
  final List<String> labels;
  final List<Color> colors;

  const _PieChart({
    required this.values,
    required this.labels,
    required this.colors,
    super.key,
  });

  @override
  State<_PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<_PieChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.values.fold<int>(0, (a, b) => a + b);
    final centerLabel = _selectedIndex == null
        ? '$total'
        : '${widget.values[_selectedIndex!]}';
    final centerDesc = _selectedIndex == null
        ? 'Yıkama'
        : widget.labels[_selectedIndex!];

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox;
            final local = box.globalToLocal(details.globalPosition);
            final center = const Offset(70, 70); // 140x140/2
            final dx = local.dx - center.dx;
            final dy = local.dy - center.dy;
            final angle = (atan2(dy, dx) + 2 * pi) % (2 * pi);
            final total = widget.values.fold<int>(0, (a, b) => a + b);
            double start = -pi / 2;
            for (int i = 0; i < widget.values.length; i++) {
              final sweep = (widget.values[i] / total) * 2 * pi;
              if (angle >= start && angle < start + sweep) {
                setState(() => _selectedIndex = i);
                return;
              }
              start += sweep;
            }
            setState(() => _selectedIndex = null);
          },
          child: CustomPaint(
            size: const Size(140, 140),
            painter: _PieChartPainter(values: widget.values, colors: widget.colors, selectedIndex: _selectedIndex),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(centerLabel, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(centerDesc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor)),
          ],
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.labels.length, (i) => Row(
              children: [
                Container(width: 12, height: 12, color: widget.colors[i]),
                const SizedBox(width: 6),
                Text(widget.labels[i], style: const TextStyle(fontSize: 12)),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;
  final int? selectedIndex;

  _PieChartPainter({required this.values, required this.colors, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    double startRadian = -pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      paint.color = colors[i].withOpacity(selectedIndex == i ? 1 : 0.5);
      canvas.drawArc(rect, startRadian, sweep, false, paint);
      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => oldDelegate.selectedIndex != selectedIndex;
} 