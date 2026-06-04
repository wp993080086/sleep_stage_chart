import 'package:flutter/material.dart';
import 'model.dart';

/// 睡眠阶段图表绘制器
class SleepStageChartPainter extends CustomPainter {
  /// 睡眠阶段图表数据
  final List<SleepStageChartSegment> data;

  /// 背景颜色
  final Color backgroundColor;

  /// 圆角半径，默认 8.0
  final double borderRadius;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 每个阶段高度比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageHeightRatio;

  /// 每个阶段色块垂直间隔比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageVerticalGapRatio;

  /// 连接线宽度，默认 1.0
  final double connectorLineWidth;

  /// 水平线样式，默认 defaultLineStyle
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直线样式，默认 defaultLineStyle
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平轴节点 0.0 ~ 1.0，默认 []
  final List<double> horizontalNodes;

  /// 垂轴节点 0.0 ~ 1.0，默认 []
  final List<double> verticalNodes;

  /// 垂直线是否可见，默认 true
  final bool verticalLineVisible;

  /// 水平线是否可见，默认 true
  final bool horizontalLineVisible;

  /// 一整天模式，默认 false
  final bool allDayMode;

  /// 整天模式下的色块颜色,默认 #43CAC4
  final Color? allDayColor;

  /// 睡眠阶段颜色映射
  final Map<SleepStageTypeEnum, Color> stageColors;

  /// 睡眠阶段顺序（从上到下），默认 [awake, core, rem, deep]
  final List<SleepStageTypeEnum>? stageOrder;

  /// 构造函数
  SleepStageChartPainter({
    required this.data,
    required this.stageHeightRatio,
    required this.stageVerticalGapRatio,
    required this.backgroundColor,
    required this.startTime,
    required this.endTime,
    this.borderRadius = 8.0,
    this.connectorLineWidth = 1.0,
    this.horizontalLineStyle = defaultLineStyle,
    this.verticalLineStyle = defaultLineStyle,
    this.verticalNodes = const [],
    this.horizontalNodes = const [],
    this.verticalLineVisible = true,
    this.horizontalLineVisible = true,
    this.allDayMode = false,
    this.allDayColor = const Color(0xFF43CAC4),
    Map<SleepStageTypeEnum, Color>? stageColors,
    this.stageOrder = defaultStageOrder,
  })  : stageColors = stageColors ?? defaultSleepStageColorsMap,
        assert(stageHeightRatio > 0 && stageHeightRatio <= 0.25,
            'stageHeightRatio 必须在 (0, 0.25] 范围内，因为 4 × stageHeightRatio ≤ 1.0'),
        assert(stageVerticalGapRatio >= 0, 'stageVerticalGapRatio 必须 ≥ 0'),
        assert(
          (stageHeightRatio * 4) + (stageVerticalGapRatio * 3) <= 1.0,
          'stageHeightRatio × 4 + stageVerticalGapRatio × 3 不能超过 1.0',
        );

  /// 图表高度（由 size.height 计算得出）
  double chartHeight = 0;

  /// 色块高度（由 chartHeight * stageHeightRatio 计算得出）
  double barHeight = 0;

  /// 底部边距（用于垂直居中计算）
  double bottomPadding = 0;

  /// 绘制图表主入口
  /// 绘制顺序：背景 -> 网格线 -> 色块区域
  @override
  void paint(Canvas canvas, Size size) {
    // 初始化图表高度
    chartHeight = size.height;

    _drawBackground(canvas, size);
    _drawLines(canvas, size);

    if (allDayMode) {
      // 整天模式：只绘制一个居中的色块
      _drawAllDayBar(canvas, size);
    } else {
      // 正常模式：计算布局参数
      // 总内容比例 = 4个色块 + 3个间距
      final double totalContentRatio =
          (stageHeightRatio * 4) + (stageVerticalGapRatio * 3);
      // 上下边距（均分剩余空间，实现垂直居中）
      final double verticalPadding = (1.0 - totalContentRatio) / 2;

      // 计算色块高度
      barHeight = chartHeight * stageHeightRatio;

      // 计算色块间距
      final double gapHeight = chartHeight * stageVerticalGapRatio;

      // 计算底部边距
      bottomPadding = chartHeight * verticalPadding;

      _drawBarArea(canvas, size, gapHeight);
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

  /// 绘制整天模式的色块（居中显示，按时间段绘制）
  /// 特点：
  /// - 只显示一个居中的色块
  /// - 按 data 中的时间段绘制，其余区域留空
  /// - 使用 allDayColor 或 unknown 类型颜色
  void _drawAllDayBar(Canvas canvas, Size size) {
    // 计算总时间跨度（秒）
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    // 计算每秒对应的像素数
    final pixelsPerSecond = size.width / totalDurationInSeconds;

    // 计算色块高度（使用 stageHeightRatio）
    final barH = chartHeight * stageHeightRatio;

    // 计算Y坐标（垂直居中）
    final barY = (chartHeight - barH) / 2;

    // 获取颜色（优先级：allDayColor > stageColors[unknown] > 灰色）
    const type = SleepStageTypeEnum.unknown;
    final color = allDayColor ?? stageColors[type] ?? Colors.grey;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 按 data 中的时间段绘制色块
    for (final detail in data) {
      // 计算色块左边界（相对于图表起点的偏移）
      final barLeft =
          detail.start.difference(startTime).inSeconds * pixelsPerSecond;
      // 计算色块宽度
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;

      // 跳过无效宽度
      if (barWidth <= 0) continue;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft,
          barY,
          barWidth,
          barH,
        ),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  /// 绘制网格线（水平线和垂直线）
  void _drawLines(Canvas canvas, Size size) {
    // 绘制水平线
    if (horizontalLineVisible) {
      final horizontalPaint = Paint()
        ..color = horizontalLineStyle.color
        ..strokeWidth = horizontalLineStyle.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      _drawHorizontalLines(canvas, size, horizontalPaint);
    }
    // 绘制垂直线
    if (verticalLineVisible) {
      final verticalPaint = Paint()
        ..color = verticalLineStyle.color
        ..strokeWidth = verticalLineStyle.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      _drawVerticalLines(canvas, size, verticalPaint);
    }
  }

  /// 绘制水平线
  void _drawHorizontalLines(Canvas canvas, Size size, Paint paint) {
    if (horizontalNodes.isEmpty) {
      return;
    }

    final dashLength = horizontalLineStyle.dashLength;
    final space = horizontalLineStyle.space;
    final strokeWidth = paint.strokeWidth;

    for (final node in horizontalNodes) {
      // 调整 Y 坐标，确保线条在画布内
      // 顶部边界 (0.0) 向下偏移一个线宽
      // 底部边界 (1.0) 向上偏移一个线宽
      double y = node * size.height;
      if (node <= 0.0) {
        y = strokeWidth;
      } else if (node >= 1.0) {
        y = size.height - strokeWidth;
      }

      if (dashLength > 0 && space > 0) {
        // 绘制虚线
        _drawDashedLine(
          canvas,
          Offset(0, y),
          Offset(size.width, y),
          paint,
          dashLength,
          space,
        );
      } else {
        // 绘制实线
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  /// 绘制垂直线
  void _drawVerticalLines(Canvas canvas, Size size, Paint paint) {
    if (verticalNodes.isEmpty) {
      return;
    }

    final dashLength = verticalLineStyle.dashLength;
    final space = verticalLineStyle.space;

    for (final node in verticalNodes) {
      final x = node * size.width;

      if (dashLength > 0 && space > 0) {
        // 绘制虚线
        _drawDashedLine(
          canvas,
          Offset(x, 0),
          Offset(x, size.height),
          paint,
          dashLength,
          space,
        );
      } else {
        // 绘制实线
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  /// 绘制虚线
  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;

    var currentDistance = 0.0;
    var isDrawing = true;

    while (currentDistance < totalDistance) {
      final segmentLength = isDrawing ? dashWidth : dashSpace;

      final remainingDistance = totalDistance - currentDistance;
      final actualLength =
          segmentLength > remainingDistance ? remainingDistance : segmentLength;

      if (isDrawing) {
        final segmentStart = start + direction * currentDistance;
        final segmentEnd = start + direction * (currentDistance + actualLength);
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance += actualLength;
      isDrawing = !isDrawing;
    }
  }

  /// 计算色块的Y坐标
  ///
  /// 根据 stageOrder 中定义的顺序（从上到下），计算指定类型色块的Y坐标
  ///
  /// 参数：
  /// - type: 睡眠阶段类型
  /// - gapHeight: 色块之间的间距
  ///
  /// 返回：
  /// - 色块顶部的Y坐标（Flutter坐标系Y向下增长）
  double _calculateBarY(SleepStageTypeEnum type, double gapHeight) {
    // 在 stageOrder 中查找索引（从上到下）
    final order = stageOrder ?? defaultStageOrder;
    final int index = order.indexOf(type);

    // 如果类型不在 stageOrder 中，默认放在最下面
    if (index < 0) {
      return chartHeight - bottomPadding - barHeight;
    }

    // 计算顶部边距（与底部边距相等，实现垂直居中）
    final double topPadding = bottomPadding;

    // 从上到下计算Y坐标：
    // Y = 顶部边距 + 索引 × (色块高度 + 间距)
    final double y = topPadding + index * (barHeight + gapHeight);
    return y;
  }

  /// 绘制睡眠阶段区域（正常模式）
  ///
  /// 绘制内容包括：
  /// 1. 相邻色块之间的连接线（渐变效果）
  /// 2. 各个睡眠阶段的色块
  void _drawBarArea(Canvas canvas, Size size, double gapHeight) {
    // 计算总时间跨度（秒）
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    // 计算每秒对应的像素数
    final pixelsPerSecond = size.width / totalDurationInSeconds;

    // 第一步：绘制相邻色块之间的连接线
    for (int i = 1; i < data.length; i++) {
      final prevDetail = data[i - 1];
      final currentDetail = data[i];

      // 只有当两个色块首尾相连时才绘制连接线
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

    // 第二步：绘制各个睡眠阶段的色块
    for (int i = 0; i < data.length; i++) {
      final detail = data[i];

      // 计算色块位置和尺寸
      final barLeft =
          detail.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;

      // 跳过无效宽度
      if (barWidth <= 0) continue;

      // 计算色块Y坐标
      final double stageY = _calculateBarY(detail.type, gapHeight);

      // 获取色块颜色
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

  /// 绘制相邻色块之间的连接线（渐变效果）
  ///
  /// 在两个相邻的睡眠阶段色块之间绘制一条渐变连接线，
  /// 颜色从上一个阶段的颜色渐变到下一个阶段的颜色
  void _drawConnectedLine({
    required Canvas canvas,
    required int currentIndex,
    required double left,
    required double gapHeight,
  }) {
    // 计算两个色块的Y坐标
    final prevBarTopY = _calculateBarY(data[currentIndex - 1].type, gapHeight);
    final currentBarTopY = _calculateBarY(data[currentIndex].type, gapHeight);

    // 计算圆角偏移量（避免连接线覆盖圆角区域）
    final cornerOffset = borderRadius * 0.7;

    // 计算连接线的顶部和底部Y坐标
    final lineTopY =
        (prevBarTopY < currentBarTopY ? prevBarTopY : currentBarTopY) +
            cornerOffset;
    final lineBottomY =
        (prevBarTopY < currentBarTopY ? currentBarTopY : prevBarTopY) +
            barHeight -
            cornerOffset;

    // 如果连接线高度无效，跳过
    if (lineTopY >= lineBottomY) {
      return;
    }

    // 获取两个色块的颜色
    final prevStageColor = stageColors[data[currentIndex - 1].type];
    final currentStageColor = stageColors[data[currentIndex].type];

    if (prevStageColor == null || currentStageColor == null) {
      return;
    }

    // 设置透明度（半透明效果）
    final prevColor = prevStageColor.withAlpha(123);
    final currentColor = currentStageColor.withAlpha(123);

    // 根据Y坐标顺序确定渐变方向
    final orderedColors = prevBarTopY < currentBarTopY
        ? [prevColor, currentColor] // 从上到下渐变
        : [currentColor, prevColor]; // 从下到上渐变

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

  /// 判断是否需要重新绘制
  ///
  /// 图表数据不变时不需要重绘，返回 false
  @override
  bool shouldRepaint(SleepStageChartPainter oldDelegate) {
    return false;
  }
}
