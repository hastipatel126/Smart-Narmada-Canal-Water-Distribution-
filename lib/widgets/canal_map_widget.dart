import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/canal_section_model.dart';
import '../../core/constants/app_constants.dart';

/// A custom-painted schematic canal network map.
/// Shows Head → Mid → Tail zones with animated flow and tappable nodes.
class CanalMapWidget extends StatefulWidget {
  final List<CanalSectionModel> sections;
  const CanalMapWidget({super.key, required this.sections});

  @override
  State<CanalMapWidget> createState() => _CanalMapWidgetState();
}

class _CanalMapWidgetState extends State<CanalMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;
  int? _tappedIndex;

  static const double _nodeRadius = 22;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  // Build zone groups from sections
  List<_ZoneNode> get _zones {
    final head = widget.sections
        .where((s) => s.sectionName.contains('Head'))
        .toList();
    final mid = widget.sections
        .where((s) => s.sectionName.contains('Mid'))
        .toList();
    final tail = widget.sections
        .where((s) => s.sectionName.contains('Tail'))
        .toList();

    final allNodes = <_ZoneNode>[];

    for (final s in head) {
      allNodes.add(_ZoneNode(
        section: s,
        label: s.sectionName.replaceAll('Head Reach – ', 'H: '),
        reachType: AppConstants.headReach,
      ));
    }
    for (final s in mid) {
      allNodes.add(_ZoneNode(
        section: s,
        label: s.sectionName.replaceAll('Mid Reach – ', 'M: '),
        reachType: AppConstants.midReach,
      ));
    }
    for (final s in tail) {
      allNodes.add(_ZoneNode(
        section: s,
        label: s.sectionName.replaceAll('Tail End – ', 'T: '),
        reachType: AppConstants.tailEnd,
      ));
    }
    return allNodes;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Critical':
        return AppTheme.danger;
      case 'Warning':
        return AppTheme.warning;
      default:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = _zones;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.map_outlined, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text('Canal Network Map',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              _legendItem('Normal', AppTheme.successColor),
              const SizedBox(width: 8),
              _legendItem('Warning', AppTheme.warning),
              const SizedBox(width: 8),
              _legendItem('Critical', AppTheme.danger),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: AnimatedBuilder(
                animation: _flowController,
                builder: (_, __) => GestureDetector(
                  onTapUp: (details) => _handleTap(details, zones, context),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _CanalPainter(
                      zones: zones,
                      flowProgress: _flowController.value,
                      tappedIndex: _tappedIndex,
                      statusColor: _statusColor,
                    ),
                  ),
                ),
              ),
            ),
            if (_tappedIndex != null && _tappedIndex! < zones.length)
              _buildInfoPanel(zones[_tappedIndex!]),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }

  void _handleTap(TapUpDetails details, List<_ZoneNode> zones,
      BuildContext context) {
    final positions = _computeNodePositions(
        MediaQuery.of(context).size.width - 48, 220, zones.length);
    final tap = details.localPosition;
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      if ((tap - pos).distance <= _nodeRadius * 1.5) {
        setState(() => _tappedIndex = _tappedIndex == i ? null : i);
        return;
      }
    }
    setState(() => _tappedIndex = null);
  }

  List<Offset> _computeNodePositions(double width, double height, int count) {
    if (count == 0) return [];
    final spacing = width / (count + 1);
    return List.generate(count, (i) => Offset(spacing * (i + 1), height / 2));
  }

  Widget _buildInfoPanel(_ZoneNode node) {
    final s = node.section;
    final color = _statusColor(s.status);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.sectionName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _infoChip('Flow', '${s.flowRate.toStringAsFixed(1)} m³/s'),
              _infoChip('Supply/Demand',
                  '${(s.supplyRatio * 100).toStringAsFixed(0)}%'),
              _infoChip('Level', '${s.waterLevel.toStringAsFixed(1)} m'),
              _infoChip('Status', s.status, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _CanalPainter extends CustomPainter {
  final List<_ZoneNode> zones;
  final double flowProgress;
  final int? tappedIndex;
  final Color Function(String) statusColor;

  static const double _nodeR = 22;

  _CanalPainter({
    required this.zones,
    required this.flowProgress,
    required this.tappedIndex,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (zones.isEmpty) return;
    final positions = _positions(size);

    _drawConnections(canvas, size, positions);
    _drawFlowParticles(canvas, positions);
    _drawNodes(canvas, positions);
    _drawLabels(canvas, positions);
  }

  List<Offset> _positions(Size size) {
    final n = zones.length;
    final spacing = size.width / (n + 1);
    return List.generate(n, (i) => Offset(spacing * (i + 1), size.height / 2));
  }

  void _drawConnections(Canvas canvas, Size size, List<Offset> positions) {
    // Main canal spine
    final spinePaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.25)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Source reservoir
    final srcX = positions.isNotEmpty ? positions[0].dx - 60 : 30.0;
    final srcY = positions.isNotEmpty ? positions[0].dy : size.height / 2;
    final srcRect = Rect.fromCenter(
        center: Offset(srcX, srcY), width: 36, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(srcRect, const Radius.circular(6)),
      Paint()..color = AppTheme.infoColor.withValues(alpha: 0.25),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(srcRect, const Radius.circular(6)),
      Paint()
        ..color = AppTheme.infoColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Connect source to first node
    if (positions.isNotEmpty) {
      canvas.drawLine(
          Offset(srcX + 18.0, srcY), positions[0], spinePaint);
    }

    // Connect all nodes
    for (int i = 0; i < positions.length - 1; i++) {
      canvas.drawLine(positions[i], positions[i + 1], spinePaint);
    }

    // Vertical drop lines per zone
    for (int i = 0; i < positions.length; i++) {
      final color = statusColor(zones[i].section.status);
      final dropPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        positions[i] + const Offset(0, _nodeR),
        positions[i] + const Offset(0, _nodeR + 28),
        dropPaint,
      );
    }
  }

  void _drawFlowParticles(Canvas canvas, List<Offset> positions) {
    if (positions.length < 2) return;
    for (int i = 0; i < positions.length - 1; i++) {
      final start = positions[i];
      final end = positions[i + 1];
      final t = (flowProgress + i * 0.3) % 1.0;
      final px = start.dx + (end.dx - start.dx) * t;
      final py = start.dy + (end.dy - start.dy) * t;
      final color = statusColor(zones[i].section.status);
      canvas.drawCircle(
        Offset(px, py),
        4,
        Paint()..color = color.withValues(alpha: 0.8),
      );
    }
  }

  void _drawNodes(Canvas canvas, List<Offset> positions) {
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final node = zones[i];
      final color = statusColor(node.section.status);
      final isSelected = tappedIndex == i;

      // Glow ring for selected
      if (isSelected) {
        canvas.drawCircle(
          pos,
          _nodeR + 8,
          Paint()..color = color.withValues(alpha: 0.2),
        );
      }

      // Outer ring
      canvas.drawCircle(
        pos,
        _nodeR + 4,
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );

      // Main node circle
      canvas.drawCircle(
        pos,
        _nodeR,
        Paint()..color = color,
      );

      // Inner white circle
      canvas.drawCircle(
        pos,
        _nodeR - 6,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );

      // Flow rate text inside node
      final flowText = '${node.section.flowRate.toStringAsFixed(0)}';
      final tp = _textPainter(flowText, 10, Colors.black87, FontWeight.w700);
      tp.layout();
      tp.paint(
          canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawLabels(Canvas canvas, List<Offset> positions) {
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final node = zones[i];

      // Short label above node
      final tp = _textPainter(node.label, 9, AppTheme.textSecondary, FontWeight.w600);
      tp.layout(maxWidth: 80);
      tp.paint(
          canvas, Offset(pos.dx - tp.width / 2, pos.dy - _nodeR - 18));

      // Supply% below drop line
      final pct =
          '${(node.section.supplyRatio * 100).toStringAsFixed(0)}%';
      final pctColor = statusColor(node.section.status);
      final tp2 = _textPainter(pct, 9, pctColor, FontWeight.w700);
      tp2.layout();
      tp2.paint(
          canvas, Offset(pos.dx - tp2.width / 2, pos.dy + _nodeR + 32));
    }
  }

  TextPainter _textPainter(
      String text, double size, Color color, FontWeight weight) {
    return TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  bool shouldRepaint(_CanalPainter old) =>
      old.flowProgress != flowProgress ||
      old.tappedIndex != tappedIndex ||
      old.zones != zones;
}

class _ZoneNode {
  final CanalSectionModel section;
  final String label;
  final String reachType;

  const _ZoneNode({
    required this.section,
    required this.label,
    required this.reachType,
  });
}
