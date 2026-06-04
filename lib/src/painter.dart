import 'package:flutter/material.dart';
import 'model.dart';

/// ============================================================================
/// 睡眠阶段图表绘制器
/// ============================================================================

/// 睡眠阶段图表自定义绘制器
///
/// 使用 Flutter CustomPainter 绘制睡眠阶段图表，包括：
/// - 背景色块
/// - 网格线（水平线和垂直线，支持虚线）
/// - 睡眠阶段色块（按类型分层显示）
/// - 相邻色块间的渐变连接线
///
/// 支持两种模式：
/// - 正常模式：显示多个睡眠阶段色块，按 [stageOrder] 顺序从上到下排列
/// - 整天模式：显示单个居中色块，用于展示整天的睡眠概览
class SleepStageChartPainter extends CustomPainter {
  /// ==========================================================================
  /// 构造参数
  /// ==========================================================================

  /// 睡眠阶段数据列表
  final List<SleepStageChartSegment> data;

  /// 图表背景颜色
  final Color backgroundColor;

  /// 色块圆角半径，默认 8.0
  final double borderRadius;

  /// 图表开始时间（X轴起点）
  final DateTime startTime;

  /// 图表结束时间（X轴终点）
  final DateTime endTime;

  /// 单个色块高度占图表总高度的比例，范围 (0, 0.25]
  ///
  /// 限制为最大 0.25，因为 4 个色块 × 0.25 = 1.0（总高度）
  final double stageHeightRatio;

  /// 相邻色块之间的间距占图表总高度的比例，范围 [0, 1.0]
  final double stageVerticalGapRatio;

  /// 相邻色块间连接线的宽度，默认 1.0
  final double connectorLineWidth;

  /// 水平网格线样式
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直网格线样式
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平线节点位置列表，范围 [0.0, 1.0]
  ///
  /// 0.0 表示顶部，1.0 表示底部
  final List<double> horizontalNodes;

  /// 垂直线节点位置列表，范围 [0.0, 1.0]
  ///
  /// 0.0 表示左侧，1.0 表示右侧
  final List<double> verticalNodes;

  /// 是否显示垂直网格线，默认 true
  final bool verticalLineVisible;

  /// 是否显示水平网格线，默认 true
  final bool horizontalLineVisible;

  /// 是否启用整天模式，默认 false
  ///
  /// 整天模式下只显示一个居中的色块，用于展示全天睡眠概览
  final bool allDayMode;

  /// 整天模式下的色块颜色，默认 Color(0xFF43CAC4)
  ///
  /// 当 [allDayMode] 为 true 时使用此颜色
  final Color? allDayColor;

  /// 睡眠阶段颜色映射表
  ///
  /// 为每种 [SleepStageTypeEnum] 指定显示颜色
  final Map<SleepStageTypeEnum, Color> stageColors;

  /// 睡眠阶段显示顺序（从上到下）
  ///
  /// 默认顺序：[awake, core, rem, deep]
  final List<SleepStageTypeEnum>? stageOrder;

  /// ==========================================================================
  /// 构造函数
  /// ==========================================================================

  /// 创建睡眠阶段图表绘制器
  ///
  /// 必需参数：
  /// - [data] - 睡眠阶段数据
  /// - [stageHeightRatio] - 色块高度比例
  /// - [stageVerticalGapRatio] - 色块间距比例
  /// - [backgroundColor] - 背景颜色
  /// - [startTime] - 开始时间
  /// - [endTime] - 结束时间
  ///
  /// 可选参数：使用默认值
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
        assert(
          stageHeightRatio > 0 && stageHeightRatio <= 0.25,
          'stageHeightRatio 必须在 (0, 0.25] 范围内，'
          '因为 4 × stageHeightRatio ≤ 1.0',
        ),
        assert(
          stageVerticalGapRatio >= 0,
          'stageVerticalGapRatio 必须 ≥ 0',
        ),
        assert(
          (stageHeightRatio * 4) + (stageVerticalGapRatio * 3) <= 1.0,
          'stageHeightRatio × 4 + stageVerticalGapRatio × 3 不能超过 1.0',
        );

  /// ==========================================================================
  /// 计算属性（在 paint 方法中初始化）
  /// ==========================================================================

  /// 图表可用高度（由 [Size.height] 计算得出）
  double _chartHeight = 0;

  /// 单个色块高度（由 [_chartHeight] × [stageHeightRatio] 计算得出）
  double _barHeight = 0;

  /// 底部边距（用于垂直居中计算）
  double _bottomPadding = 0;

  /// ==========================================================================
  /// 绘制入口
  /// ==========================================================================

  /// 主绘制方法
  ///
  /// 绘制顺序：
  /// 1. 绘制背景
  /// 2. 绘制网格线（水平线和垂直线）
  /// 3. 绘制色块区域（正常模式或整天模式）
  @override
  void paint(Canvas canvas, Size size) {
    // 初始化图表高度
    _chartHeight = size.height;

    // 绘制背景
    _drawBackground(canvas, size);

    // 绘制网格线
    _drawGridLines(canvas, size);

    // 根据模式绘制色块
    if (allDayMode) {
      _drawAllDayModeBars(canvas, size);
    } else {
      _drawNormalModeBars(canvas, size);
    }
  }

  /// ==========================================================================
  /// 背景绘制
  /// ==========================================================================

  /// 绘制图表背景
  ///
  /// 使用 [backgroundColor] 填充整个图表区域
  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }

  /// ==========================================================================
  /// 网格线绘制
  /// ==========================================================================

  /// 绘制网格线（水平线和垂直线）
  void _drawGridLines(Canvas canvas, Size size) {
    // 绘制水平线
    if (horizontalLineVisible && horizontalNodes.isNotEmpty) {
      _drawHorizontalLines(canvas, size);
    }

    // 绘制垂直线
    if (verticalLineVisible && verticalNodes.isNotEmpty) {
      _drawVerticalLines(canvas, size);
    }
  }

  /// 绘制水平网格线
  ///
  /// 根据 [horizontalNodes] 中定义的位置绘制水平线
  /// 支持实线和虚线两种样式
  void _drawHorizontalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = horizontalLineStyle.color
      ..strokeWidth = horizontalLineStyle.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final dashLength = horizontalLineStyle.dashLength;
    final space = horizontalLineStyle.space;
    final strokeWidth = paint.strokeWidth;

    for (final node in horizontalNodes) {
      // 计算 Y 坐标，并进行边界调整
      // 顶部边界 (0.0) 向下偏移一个线宽，确保线条完全可见
      // 底部边界 (1.0) 向上偏移一个线宽，确保线条完全可见
      double y = node * size.height;
      if (node <= 0.0) {
        y = strokeWidth;
      } else if (node >= 1.0) {
        y = size.height - strokeWidth;
      }

      // 根据样式绘制实线或虚线
      if (dashLength > 0 && space > 0) {
        _drawDashedLine(
          canvas: canvas,
          start: Offset(0, y),
          end: Offset(size.width, y),
          paint: paint,
          dashLength: dashLength,
          space: space,
        );
      } else {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  /// 绘制垂直网格线
  ///
  /// 根据 [verticalNodes] 中定义的位置绘制垂直线
  /// 支持实线和虚线两种样式
  void _drawVerticalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = verticalLineStyle.color
      ..strokeWidth = verticalLineStyle.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final dashLength = verticalLineStyle.dashLength;
    final space = verticalLineStyle.space;

    for (final node in verticalNodes) {
      final x = node * size.width;

      // 根据样式绘制实线或虚线
      if (dashLength > 0 && space > 0) {
        _drawDashedLine(
          canvas: canvas,
          start: Offset(x, 0),
          end: Offset(x, size.height),
          paint: paint,
          dashLength: dashLength,
          space: space,
        );
      } else {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  /// 绘制虚线
  ///
  /// 在 [start] 和 [end] 之间绘制虚线
  ///
  /// 参数：
  /// - [canvas] - 画布对象
  /// - [start] - 起点坐标
  /// - [end] - 终点坐标
  /// - [paint] - 画笔样式
  /// - [dashLength] - 每段虚线长度
  /// - [space] - 虚线间隔长度
  void _drawDashedLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Paint paint,
    required double dashLength,
    required double space,
  }) {
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;

    var currentDistance = 0.0;
    var isDrawingDash = true;

    while (currentDistance < totalDistance) {
      final segmentLength = isDrawingDash ? dashLength : space;
      final remainingDistance = totalDistance - currentDistance;
      final actualLength =
          segmentLength > remainingDistance ? remainingDistance : segmentLength;

      if (isDrawingDash) {
        final segmentStart = start + direction * currentDistance;
        final segmentEnd = start + direction * (currentDistance + actualLength);
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance += actualLength;
      isDrawingDash = !isDrawingDash;
    }
  }

  /// ==========================================================================
  /// 整天模式绘制
  /// ==========================================================================

  /// 绘制整天模式的色块
  ///
  /// 特点：
  /// - 只显示一个垂直居中的色块
  /// - 按 [data] 中的时间段绘制，其余区域留空
  /// - 使用 [allDayColor] 或 unknown 类型颜色
  void _drawAllDayModeBars(Canvas canvas, Size size) {
    // 计算总时间跨度（秒）
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    // 计算每秒对应的像素数
    final pixelsPerSecond = size.width / totalDurationInSeconds;

    // 计算色块高度
    final barHeight = _chartHeight * stageHeightRatio;

    // 计算 Y 坐标（垂直居中）
    final barTopY = (_chartHeight - barHeight) / 2;

    // 获取颜色（优先级：allDayColor > stageColors[unknown] > 灰色）
    final color =
        allDayColor ?? stageColors[SleepStageTypeEnum.unknown] ?? Colors.grey;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 按 data 中的时间段绘制色块
    for (final segment in data) {
      final barLeft =
          segment.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          segment.end.difference(segment.start).inSeconds * pixelsPerSecond;

      // 跳过无效宽度
      if (barWidth <= 0) continue;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft,
          barTopY,
          barWidth,
          barHeight,
        ),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  /// ==========================================================================
  /// 正常模式绘制
  /// ==========================================================================

  /// 绘制正常模式的睡眠阶段色块
  ///
  /// 绘制流程：
  /// 1. 计算布局参数（色块高度、间距、边距）
  /// 2. 绘制相邻色块间的渐变连接线
  /// 3. 绘制各个睡眠阶段的色块
  void _drawNormalModeBars(Canvas canvas, Size size) {
    // 计算总内容比例 = 4个色块 + 3个间距
    final totalContentRatio =
        (stageHeightRatio * 4) + (stageVerticalGapRatio * 3);

    // 上下边距（均分剩余空间，实现垂直居中）
    final verticalPadding = (1.0 - totalContentRatio) / 2;

    // 计算色块高度
    _barHeight = _chartHeight * stageHeightRatio;

    // 计算色块间距
    final gapHeight = _chartHeight * stageVerticalGapRatio;

    // 计算底部边距
    _bottomPadding = _chartHeight * verticalPadding;

    // 计算总时间跨度（秒）
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    // 计算每秒对应的像素数
    final pixelsPerSecond = size.width / totalDurationInSeconds;

    // 第一步：绘制相邻色块之间的连接线
    _drawConnectorLines(canvas, pixelsPerSecond, gapHeight);

    // 第二步：绘制各个睡眠阶段的色块
    _drawStageBars(canvas, pixelsPerSecond, gapHeight, size.width);
  }

  /// 绘制相邻色块间的渐变连接线
  ///
  /// 当两个色块首尾相连时，在它们之间绘制一条渐变连接线
  void _drawConnectorLines(
      Canvas canvas, double pixelsPerSecond, double gapHeight) {
    for (int i = 1; i < data.length; i++) {
      final prevSegment = data[i - 1];
      final currentSegment = data[i];

      // 只有当两个色块首尾相连时才绘制连接线
      if (prevSegment.end == currentSegment.start) {
        final connectorLeft =
            prevSegment.end.difference(startTime).inSeconds * pixelsPerSecond;

        _drawSingleConnectorLine(
          canvas: canvas,
          currentIndex: i,
          left: connectorLeft,
          gapHeight: gapHeight,
        );
      }
    }
  }

  /// 绘制单个连接线
  ///
  /// 在两个相邻的睡眠阶段色块之间绘制渐变连接线
  void _drawSingleConnectorLine({
    required Canvas canvas,
    required int currentIndex,
    required double left,
    required double gapHeight,
  }) {
    // 计算两个色块的 Y 坐标
    final prevBarTopY =
        _calculateBarTopY(data[currentIndex - 1].type, gapHeight);
    final currentBarTopY =
        _calculateBarTopY(data[currentIndex].type, gapHeight);

    // 计算圆角偏移量（避免连接线覆盖圆角区域）
    final cornerOffset = borderRadius * 0.7;

    // 计算连接线的顶部和底部 Y 坐标
    final lineTopY =
        (prevBarTopY < currentBarTopY ? prevBarTopY : currentBarTopY) +
            cornerOffset;
    final lineBottomY =
        (prevBarTopY < currentBarTopY ? currentBarTopY : prevBarTopY) +
            _barHeight -
            cornerOffset;

    // 如果连接线高度无效，跳过
    if (lineTopY >= lineBottomY) return;

    // 获取两个色块的颜色
    final prevColor = stageColors[data[currentIndex - 1].type];
    final currentColor = stageColors[data[currentIndex].type];

    if (prevColor == null || currentColor == null) return;

    // 设置透明度（半透明效果）
    final prevColorWithAlpha = prevColor.withAlpha(123);
    final currentColorWithAlpha = currentColor.withAlpha(123);

    // 根据 Y 坐标顺序确定渐变方向
    final gradientColors = prevBarTopY < currentBarTopY
        ? [prevColorWithAlpha, currentColorWithAlpha] // 从上到下渐变
        : [currentColorWithAlpha, prevColorWithAlpha]; // 从下到上渐变

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
        colors: gradientColors,
      ).createShader(lineRect);

    canvas.drawRect(lineRect, connectPaint);
  }

  /// 绘制睡眠阶段色块
  ///
  /// 遍历 [data] 中的每个阶段，计算位置和尺寸后绘制
  void _drawStageBars(Canvas canvas, double pixelsPerSecond, double gapHeight,
      double maxWidth) {
    for (final segment in data) {
      // 计算色块位置和尺寸
      final barLeft =
          segment.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          segment.end.difference(segment.start).inSeconds * pixelsPerSecond;

      // 跳过无效宽度
      if (barWidth <= 0) continue;

      // 计算色块 Y 坐标
      final barTopY = _calculateBarTopY(segment.type, gapHeight);

      // 获取色块颜色
      final color = stageColors[segment.type];
      if (color == null) continue;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // 计算实际绘制宽度，确保不超出画布边界
      final drawWidth =
          (barLeft + barWidth > maxWidth) ? maxWidth - barLeft : barWidth;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft,
          barTopY,
          drawWidth,
          _barHeight,
        ),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  /// ==========================================================================
  /// 辅助计算方法
  /// ==========================================================================

  /// 计算色块的顶部 Y 坐标
  ///
  /// 根据 [stageOrder] 中定义的顺序（从上到下），计算指定类型色块的 Y 坐标
  ///
  /// 参数：
  /// - [type] - 睡眠阶段类型
  /// - [gapHeight] - 色块之间的间距（像素）
  ///
  /// 返回：
  /// - 色块顶部的 Y 坐标（Flutter 坐标系 Y 向下增长）
  double _calculateBarTopY(SleepStageTypeEnum type, double gapHeight) {
    // 在 stageOrder 中查找索引（从上到下）
    final order = stageOrder ?? defaultStageOrder;
    final index = order.indexOf(type);

    // 如果类型不在 stageOrder 中，默认放在最下面
    if (index < 0) {
      return _chartHeight - _bottomPadding - _barHeight;
    }

    // 计算顶部边距（与底部边距相等，实现垂直居中）
    final topPadding = _bottomPadding;

    // 从上到下计算 Y 坐标：
    // Y = 顶部边距 + 索引 × (色块高度 + 间距)
    return topPadding + index * (_barHeight + gapHeight);
  }

  /// ==========================================================================
  /// 重绘判断
  /// ==========================================================================

  /// 判断是否需要重新绘制
  ///
  /// 图表数据不变时不需要重绘，返回 false
  ///
  /// 由于所有绘制参数都是 final 的，图表内容不会改变，
  /// 因此始终返回 false 以提高性能
  @override
  bool shouldRepaint(covariant SleepStageChartPainter oldDelegate) {
    return false;
  }
}
