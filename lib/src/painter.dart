import 'package:flutter/material.dart';
import 'model.dart';

/// 睡眠阶段图表绘制器
class SleepStageChartPainter extends CustomPainter {
  /// 睡眠阶段图表数据
  final List<SleepStageChartSegment> data;

  /// 背景颜色
  final Color backgroundColor;

  /// 圆角半径
  final double borderRadius;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 每个阶段高度比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageHeightRatio;

  /// 每个阶段色块垂直间隔比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageVerticalGapRatio;

  /// 连接线宽度
  final double connectorLineWidth;

  /// 水平线样式
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直线样式
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平轴节点 0.0 ~ 1.0
  final List<double> horizontalNodes;

  /// 垂轴节点 0.0 ~ 1.0
  final List<double> verticalNodes;

  /// 垂直线是否可见
  final bool verticalLineVisible;

  /// 水平线是否可见
  final bool horizontalLineVisible;

  /// 是否包含指示器
  final bool hasIndicator;

  /// 是否显示指示器
  final bool indicatorVisible;

  /// 指示器位置 0.0 ~ 1.0
  double indicatorPosition;

  /// 一整天模式 默认false
  final bool allDayMode;

  /// 睡眠阶段颜色映射
  final Map<SleepStageTypeEnum, Color> stageColors;

  /// 睡眠阶段顺序（从上到下），默认 [awake, core, rem, deep]
  final List<SleepStageTypeEnum>? stageOrder;

  /// 日期格式化函数
  final String Function(DateTime)? dateFormatter;

  /// 图表高度
  double chartHeight = 0;

  /// 图表条高度
  double barHeight = 0;

  /// 底部边距
  double bottomPadding = 0;

  /// 构造函数
  SleepStageChartPainter({
    required this.data,
    required this.stageHeightRatio,
    required this.stageVerticalGapRatio,
    required this.backgroundColor,
    required this.startTime,
    required this.endTime,
    this.borderRadius = 4.0,
    this.connectorLineWidth = 1.0,
    this.horizontalLineStyle = defaultLineStyle,
    this.verticalLineStyle = defaultLineStyle,
    this.verticalNodes = const [],
    this.horizontalNodes = const [],
    this.verticalLineVisible = true,
    this.horizontalLineVisible = true,
    this.indicatorPosition = 0.0,
    this.hasIndicator = true,
    this.indicatorVisible = false,
    this.allDayMode = false,
    Map<SleepStageTypeEnum, Color>? stageColors,
    this.stageOrder = defaultStageOrder,
    String Function(DateTime)? dateFormatter,
  })  : stageColors = stageColors ?? defaultSleepStageColorsMap,
        dateFormatter = dateFormatter ?? formatTimeToHHMM,
        assert(stageHeightRatio > 0 && stageHeightRatio <= 0.25,
            'stageHeightRatio 必须在 (0, 0.25] 范围内，因为 4 × stageHeightRatio ≤ 1.0'),
        assert(stageVerticalGapRatio >= 0, 'stageVerticalGapRatio 必须 ≥ 0'),
        assert(
          (stageHeightRatio * 4) + (stageVerticalGapRatio * 3) <= 1.0,
          'stageHeightRatio × 4 + stageVerticalGapRatio × 3 不能超过 1.0',
        );

  /// 绘制图表
  @override
  void paint(Canvas canvas, Size size) {
    /// 上下边距（均分剩余空间）
    final double totalContentRatio =
        (stageHeightRatio * 4) + (stageVerticalGapRatio * 3);
    final double verticalPadding = (1.0 - totalContentRatio) / 2;

    /// 图表高度
    chartHeight = size.height;

    /// 色块高度
    barHeight = chartHeight * stageHeightRatio;

    /// 色块间距
    final double gapHeight = chartHeight * stageVerticalGapRatio;

    /// 底部边距
    bottomPadding = chartHeight * verticalPadding;

    _drawBackground(canvas, size);
    _drawLines(canvas, size);
    _drawBarArea(canvas, size, gapHeight);
    if (hasIndicator && indicatorVisible) {
      _drawIndicator(canvas, size);
      _drawTitle(canvas, size);
    }
  }

  /// 绘制背景
  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  /// 绘制线
  void _drawLines(Canvas canvas, Size size) {
    final dividerPaint = Paint()
      ..color = horizontalLineStyle.color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    if (horizontalLineVisible) {
      _drawHorizontalLines(canvas, size, dividerPaint);
    }
    if (verticalLineVisible) {
      _drawVerticalLines(canvas, size, dividerPaint);
    }
  }

  /// 绘制水平线
  void _drawHorizontalLines(Canvas canvas, Size size, Paint paint) {
    if (horizontalNodes.isEmpty) {
      return;
    }

    for (final node in horizontalNodes) {
      final y = node * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// 绘制垂直线
  void _drawVerticalLines(Canvas canvas, Size size, Paint paint) {
    if (verticalNodes.isEmpty) {
      return;
    }

    for (final node in verticalNodes) {
      final x = node * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  /// 计算色块的Y坐标
  /// stageOrder 定义了从上到下的顺序，index 0 在最上方
  double _calculateBarY(SleepStageTypeEnum type, double gapHeight) {
    // 在 stageOrder 中查找索引（从上到下）
    final int index = stageOrder?.indexOf(type) ?? 0;
    if (index < 0) {
      // 如果类型不在 stageOrder 中，默认放在最下面
      return chartHeight - bottomPadding - barHeight;
    }
    // 从上到下计算Y坐标（Flutter坐标系Y向下增长）
    // 最上方的Y = topPadding
    final double topPadding = bottomPadding;
    final double y = topPadding + index * (barHeight + gapHeight);
    return y;
  }

  /// 绘制睡眠阶段区域
  void _drawBarArea(Canvas canvas, Size size, double gapHeight) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    for (int i = 1; i < data.length; i++) {
      final prevDetail = data[i - 1];
      final currentDetail = data[i];

      if (prevDetail.end == currentDetail.start) {
        final connectorLeft =
            prevDetail.end.difference(startTime).inSeconds * pixelsPerSecond;
        _drawConnectedLine(
          canvas: canvas,
          currentIndex: i,
          left: connectorLeft,
          gapHeight: gapHeight,
        );
      }
    }

    for (int i = 0; i < data.length; i++) {
      final detail = data[i];
      final barLeft =
          detail.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;

      if (barWidth <= 0) continue;

      final double stageY = _calculateBarY(detail.type, gapHeight);

      final color = stageColors[detail.type];
      if (color == null) continue;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft,
          stageY,
          barWidth + connectorLineWidth,
          barHeight,
        ),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  /// 绘制连接线
  void _drawConnectedLine({
    required Canvas canvas,
    required int currentIndex,
    required double left,
    required double gapHeight,
  }) {
    final prevBarTopY = _calculateBarY(data[currentIndex - 1].type, gapHeight);
    final currentBarTopY = _calculateBarY(data[currentIndex].type, gapHeight);

    final cornerOffset = borderRadius * 0.7;

    final lineTopY =
        (prevBarTopY < currentBarTopY ? prevBarTopY : currentBarTopY) +
            cornerOffset;
    final lineBottomY =
        (prevBarTopY < currentBarTopY ? currentBarTopY : prevBarTopY) +
            barHeight -
            cornerOffset;

    if (lineTopY >= lineBottomY) {
      return;
    }

    final prevStageColor = stageColors[data[currentIndex - 1].type];
    final currentStageColor = stageColors[data[currentIndex].type];

    if (prevStageColor == null || currentStageColor == null) {
      return;
    }

    final prevColor = prevStageColor.withAlpha(123);
    final currentColor = currentStageColor.withAlpha(123);

    final orderedColors = prevBarTopY < currentBarTopY
        ? [prevColor, currentColor]
        : [currentColor, prevColor];

    final lineRect = Rect.fromLTWH(
      left,
      lineTopY,
      connectorLineWidth,
      lineBottomY - lineTopY,
    );

    final connectPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: orderedColors,
      ).createShader(lineRect);

    canvas.drawRect(lineRect, connectPaint);
  }

  /// 绘制标题
  void _drawTitle(Canvas canvas, Size size) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    SleepStageChartSegment? currentStage;
    double stageStartX = 0;
    double stageWidth = 0;

    for (final detail in data) {
      final barLeft =
          detail.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;
      final barRight = barLeft + barWidth;

      if (indicatorPosition >= barLeft && indicatorPosition <= barRight) {
        currentStage = detail;
        stageStartX = barLeft;
        stageWidth = barWidth;
        break;
      }
    }

    if (currentStage == null) {
      return;
    }

    const textTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    const textSubTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    String stageName;
    switch (currentStage.type) {
      case SleepStageTypeEnum.core:
        stageName = 'Light';
        break;
      case SleepStageTypeEnum.deep:
        stageName = 'Deep';
        break;
      case SleepStageTypeEnum.rem:
        stageName = 'REM';
        break;
      case SleepStageTypeEnum.awake:
        stageName = 'Awake';
        break;
      default:
        stageName = 'Unknown';
    }
    if (currentStage.titles.isNotEmpty) {
      stageName = currentStage.titles.join();
    }

    final String scopeText =
        '${formatTimeToHHMM(currentStage.start)}~${formatTimeToHHMM(currentStage.end)}';
    final durationSec =
        currentStage.end.difference(currentStage.start).inSeconds;
    final durationMin = (durationSec / 60).ceil();
    final String durationText = formatTimeMinute(durationMin);
    final textPainter = TextPainter(
      text: TextSpan(
        text: durationText,
        style: textTitleStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    final timeRangePainter = TextPainter(
      text: TextSpan(
        text: '$stageName $scopeText',
        style: textSubTitleStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    timeRangePainter.layout();

    const bgWidth = 137.0;
    const bgHeight = 52.0;

    double bgX = stageStartX + (stageWidth / 2) - (bgWidth / 2);

    if (bgX < 0) {
      bgX = 0;
    } else if (bgX + bgWidth > size.width) {
      bgX = size.width - bgWidth;
    }

    const bgY = 0.0;

    final stageColor = stageColors[currentStage.type];
    if (stageColor == null) return;

    final bgPaint = Paint()
      ..color = stageColor
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bgX, bgY, bgWidth, bgHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(bgRect, bgPaint);

    final x = bgX + 12;
    const y = bgY + 6;
    textPainter.paint(canvas, Offset(x, y));

    final timeX = bgX + 12;
    const timeY = bgY + 28;
    timeRangePainter.paint(canvas, Offset(timeX, timeY));
  }

  /// 绘制指示器
  void _drawIndicator(Canvas canvas, Size size) {
    final indicatorPaint = Paint()
      ..color = const Color(0xFF8186B3).withAlpha(123)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = indicatorPosition;
    const startY = 0.0;
    final endY = size.height;

    canvas.drawLine(
      Offset(centerX, startY),
      Offset(centerX, endY),
      indicatorPaint,
    );
  }

  /// 重新绘制
  @override
  bool shouldRepaint(SleepStageChartPainter oldDelegate) {
    return oldDelegate.indicatorPosition != indicatorPosition ||
        oldDelegate.indicatorVisible != indicatorVisible;
  }
}
