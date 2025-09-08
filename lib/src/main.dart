import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:math' as math;

/// 睡眠阶段图表绘制
/// 根据传入的参数绘制图表，包括背景、网格线、标题、条形图和底部信息等
class SleepStageChartPainter extends CustomPainter {
  /// 高度单位，用于计算条形图的高度
  final double heightUnit;

  /// X轴标题的偏移量
  final double xAxisTitleOffset;

  /// 图表背景颜色
  final Color backgroundColor;

  /// 睡眠详情数据列表
  final List<SleepStageDetails> details;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// X轴标题的高度
  final double xAxisTitleHeight;

  /// 色块的圆角半径
  final double borderRadius;

  /// 连接线的宽度
  final double connectorLineWidth;

  /// 指示器的水平位置
  double indicatorPosition;

  /// 水平网格线的样式
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直网格线的样式
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平分为几块 默认分为8块，带上边框一共9条线
  final int horizontalLineCount;

  /// 网格线的画笔样式
  final SleepStageChartPaintStyle dividerPaintStyle;

  /// 不同睡眠阶段对应的颜色映射
  final Map<SleepStageEnum, Color> stageColors;

  /// 底部信息的文本样式
  final TextStyle bottomInfoTextStyle;

  /// 日期格式化函数
  final String Function(DateTime) dateFormatter;

  /// 是否绘制垂直网格线
  final bool showVerticalLine;

  /// 是否绘制水平网格线
  final bool showHorizontalLine;

  /// 是否有指示器 默认有
  final bool hasIndicator;

  /// 指示器是否可见（由外部控制的显示状态 默认不可见）
  final bool isIndicatorVisible;

  /// 默认的睡眠阶段颜色映射
  static final Map<SleepStageEnum, Color> _defaultStageColors = {
    SleepStageEnum.light: const Color(0xFF54B0FF), // 浅睡阶段
    SleepStageEnum.deep: const Color(0xFF4D58E7), // 深睡阶段
    SleepStageEnum.rem: const Color(0xFF82DDDD), // REM(快速眼动)阶段
    SleepStageEnum.awake: const Color(0xFFFFA877), // 清醒阶段
  };

  /// 默认的底部信息文本样式
  static const TextStyle _defaultBottomInfoTextStyle = TextStyle(
    color: Color(0xFF666666),
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// 默认的日期格式化函数，格式：MM-DD HH:mm
  static String _defaultDateFormatter(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 图表实际高度
  double chartHeight = 0;

  /// 条形图的高度
  double barHeight = 0;

  /// 起始高度
  double startHeight = 0;

  SleepStageChartPainter({
    required this.heightUnit,
    required this.xAxisTitleOffset,
    required this.backgroundColor,
    required this.details,
    required this.startTime,
    required this.endTime,
    required this.xAxisTitleHeight,
    this.borderRadius = 8.0,
    this.connectorLineWidth = 2.0,
    this.horizontalLineStyle =
        const SleepStageChartLineStyle(width: 5.0, space: 3.0),
    this.verticalLineStyle =
        const SleepStageChartLineStyle(width: 5.0, space: 3.0),
    // 默认分为8块，带上边框一共9条线
    this.horizontalLineCount = 8,
    this.dividerPaintStyle = const SleepStageChartPaintStyle(
      color: Color(0xFFEEEEEE),
      strokeWidth: 1.0,
      style: PaintingStyle.stroke,
      strokeCap: StrokeCap.round,
    ),
    Map<SleepStageEnum, Color>? stageColors,
    TextStyle? bottomInfoTextStyle,
    String Function(DateTime)? dateFormatter,
    // 默认位置为0
    this.indicatorPosition = 0.0,
    // 默认绘制
    this.showVerticalLine = true,
    // 默认绘制
    this.showHorizontalLine = true,
    // 是否有指示器 默认有
    this.hasIndicator = true,
    // 默认指示器不可见（需要触摸才显示）
    this.isIndicatorVisible = false,
  })  : stageColors = stageColors ?? _defaultStageColors,
        bottomInfoTextStyle =
            bottomInfoTextStyle ?? _defaultBottomInfoTextStyle,
        dateFormatter = dateFormatter ?? _defaultDateFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    // 在paint方法中根据size计算实际值
    chartHeight = (size.height - xAxisTitleOffset - xAxisTitleHeight);
    barHeight = chartHeight * heightUnit;
    startHeight = chartHeight * heightUnit;

    // 定义一个底部间距（暂时为0）
    const double bottomPadding = 0.0;

    // 基于这个有效高度来计算每个色块的高度和层级单位高度
    final double effectiveChartHeight =
        (chartHeight - bottomPadding) > 0 ? (chartHeight - bottomPadding) : 0;

    // 4. 基于这个有效高度来计算每个色块的高度和层级单位高度
    // 这样所有色块就会被绘制在上方，底部自然留出空白
    barHeight = effectiveChartHeight * heightUnit;
    startHeight = effectiveChartHeight * heightUnit;

    // 绘制背景
    _drawBackground(canvas, size);
    // 绘制线条
    _drawLines(canvas, size);
    // 绘制条形图和连接线
    _drawBarArea(canvas, size);
    // 绘制底部信息
    _drawBottomInfo(canvas, size);

    // 绘制指示条和绘制标题（仅当指示器可见时）
    if (hasIndicator && isIndicatorVisible) {
      // 绘制指示条
      _drawIndicator(canvas, size);
      // 绘制标题
      _drawTitle(canvas, size);
    }
  }

  /// 绘制背景
  /// 在图表区域绘制纯色背景
  void _drawBackground(Canvas canvas, Size size) {
    final chartHeight = (size.height - xAxisTitleOffset - xAxisTitleHeight);
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, chartHeight), backgroundPaint);
  }

  /// 绘制网格线
  /// 包括水平网格线和垂直网格线
  void _drawLines(Canvas canvas, Size size) {
    final dividerPaint = Paint()
      ..color = dividerPaintStyle.color
      ..strokeWidth = dividerPaintStyle.strokeWidth
      ..style = dividerPaintStyle.style
      ..strokeCap = dividerPaintStyle.strokeCap;

    if (showHorizontalLine) {
      _drawHorizontalLines(canvas, size, dividerPaint);
    }
    if (showVerticalLine) {
      _drawVerticalLines(canvas, size, dividerPaint);
    }
  }

  /// 绘制水平网格线
  /// 根据horizontalLineCount参数绘制等间距的水平虚线
  void _drawHorizontalLines(Canvas canvas, Size size, Paint paint) {
    // 添加保护，防止因width和space总和<=0导致无限循环
    if (horizontalLineStyle.width + horizontalLineStyle.space <= 0) {
      return;
    }

    final lineSpacing = chartHeight / horizontalLineCount;

    for (int i = 0; i <= horizontalLineCount; i++) {
      final y = (i * lineSpacing);
      double startX = 0;
      while (startX < size.width) {
        // 使用 min 函数确保终点不会超过图表宽度
        final double endX =
            math.min(startX + horizontalLineStyle.width, size.width);
        // 绘制
        canvas.drawLine(
          Offset(startX, y),
          Offset(endX, y),
          paint,
        );
        startX += horizontalLineStyle.width + horizontalLineStyle.space;
      }
    }
  }

  /// 绘制垂直网格线
  /// 在图表左右两侧绘制等间距的垂直虚线
  void _drawVerticalLines(Canvas canvas, Size size, Paint paint) {
    // 添加保护，防止因width和space总和<=0导致无限循环
    if (verticalLineStyle.width + verticalLineStyle.space <= 0) {
      return;
    }

    double startY = 0.0;
    final endY = chartHeight;

    while (startY < endY) {
      // 计算安全终点，确保不超过图表底部
      final double safeEndY = math.min(startY + verticalLineStyle.width, endY);
      // 左侧垂直线
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, safeEndY),
        paint,
      );
      // 右侧垂直线
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, safeEndY),
        paint,
      );
      startY += verticalLineStyle.width + verticalLineStyle.space;
    }
  }

  /// 绘制睡眠阶段条形图和连接线
  /// 调整绘制顺序，先画所有连接线，再画所有色块，以实现覆盖效果
  void _drawBarArea(
    Canvas canvas,
    Size size,
  ) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    // 第一步: 绘制所有连接线
    for (int i = 1; i < details.length; i++) {
      final prevDetail = details[i - 1];
      final currentDetail = details[i];

      // 只有当两个阶段是连续的时候才绘制连接线
      if (prevDetail.endTime == currentDetail.startTime) {
        final connectorLeft =
            prevDetail.endTime.difference(startTime).inSeconds *
                pixelsPerSecond;
        _drawConnectedLine(
          canvas: canvas,
          currentIndex: i,
          left: connectorLeft,
        );
      }
    }

    // 第二步: 在上层绘制所有色块 (处理数据不连续，留空)
    for (int i = 0; i < details.length; i++) {
      final detail = details[i];
      final barLeft =
          detail.startTime.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth = detail.endTime.difference(detail.startTime).inSeconds *
          pixelsPerSecond;

      if (barWidth <= 0) continue;

      final double endY = startHeight * getHeightByStage(detail.model);
      final double startY = endY;

      final paint = Paint()
        ..color = stageColors[detail.model]!
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft,
          startY,
          barWidth + connectorLineWidth,
          barHeight,
        ),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  /// 绘制条形之间的连接线
  /// 使用drawRect代替drawLine来精确控制连接线的位置和融合效果
  void _drawConnectedLine({
    required Canvas canvas,
    required int currentIndex,
    required double left,
  }) {
    // 上一个bar的顶部Y坐标
    final prevBarTopY =
        (startHeight * getHeightByStage(details[currentIndex - 1].model));
    // 当前bar的顶部Y坐标
    final currentBarTopY =
        (startHeight * getHeightByStage(details[currentIndex].model));

    // 考虑圆角的偏移量，使连接线不会超出色块的圆角部分
    final cornerOffset = borderRadius * 0.7; // 使用圆角半径的70%作为偏移量

    // 决定连接线的顶部和底部，考虑圆角
    final lineTopY =
        (prevBarTopY < currentBarTopY ? prevBarTopY : currentBarTopY) +
            cornerOffset;
    final lineBottomY =
        (prevBarTopY < currentBarTopY ? currentBarTopY : prevBarTopY) +
            barHeight -
            cornerOffset;

    // 如果没有足够的空间绘制连接线，则不绘制
    if (lineTopY >= lineBottomY) {
      return;
    }

    // 直接从stageColors获取颜色
    final prevColor =
        (stageColors[details[currentIndex - 1].model] ?? Colors.transparent)
            .withAlpha(123);
    final currentColor =
        (stageColors[details[currentIndex].model] ?? Colors.transparent)
            .withAlpha(123);

    // 确保渐变方向与bar的位置匹配
    final orderedColors = prevBarTopY < currentBarTopY
        ? [prevColor, currentColor]
        : [currentColor, prevColor];

    // 将连接线完全放在左侧色块内部，而不是居中于边界
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
      ).createShader(lineRect); // 使用lineRect来定义渐变范围

    // 绘制矩形连接线
    canvas.drawRect(lineRect, connectPaint);
  }

  /// 绘制标题区域
  /// 包括睡眠阶段名称、时长和时间范围
  void _drawTitle(Canvas canvas, Size size) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    SleepStageDetails? currentStage;
    double stageStartX = 0;
    double stageWidth = 0;

    for (final detail in details) {
      final barLeft =
          detail.startTime.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth = detail.endTime.difference(detail.startTime).inSeconds *
          pixelsPerSecond;
      final barRight = barLeft + barWidth;

      if (indicatorPosition >= barLeft && indicatorPosition <= barRight) {
        currentStage = detail;
        stageStartX = barLeft;
        stageWidth = barWidth;
        break; // 找到后即可退出
      }
    }

    // 如果没有找到对应的阶段，直接返回不显示标题
    if (currentStage == null) {
      return;
    }

    // 创建文本样式
    const textTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    const textSubTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    // 根据睡眠阶段设置标题文本
    String stageName;
    switch (currentStage.model) {
      case SleepStageEnum.light:
        stageName = 'Light';
        break;
      case SleepStageEnum.deep:
        stageName = 'Deep';
        break;
      case SleepStageEnum.rem:
        stageName = 'REM';
        break;
      case SleepStageEnum.awake:
        stageName = 'Awake';
        break;
      default:
        stageName = 'Unknown';
    }

    // 创建主标题文本画笔
    final String scopeText =
        '${formatTimeToHHMM(currentStage.startTime)} ~ ${formatTimeToHHMM(currentStage.endTime)}';
    final String durationText = formatTimeMinute(currentStage.duration);
    final textPainter = TextPainter(
      text: TextSpan(
        text: durationText,
        style: textTitleStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    // 创建时间范围文本画笔
    final timeRangePainter = TextPainter(
      text: TextSpan(
        text: '$stageName $scopeText',
        style: textSubTitleStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    // 布局文本
    textPainter.layout();
    timeRangePainter.layout();

    // 计算背景矩形位置
    const bgWidth = 137.0;
    const bgHeight = 52.0;

    // 计算标题位置，使用当前阶段的中心点
    double bgX = stageStartX + (stageWidth / 2) - (bgWidth / 2);

    // 限制标题不超出边界
    if (bgX < 0) {
      bgX = 0;
    } else if (bgX + bgWidth > size.width) {
      bgX = size.width - bgWidth;
    }

    const bgY = bgHeight / 2;

    // 绘制半透明背景
    final bgPaint = Paint()
      ..color = stageColors[currentStage.model]! // 使用当前阶段的颜色
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bgX, bgY, bgWidth, bgHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 绘制主标题
    final x = bgX + 12; // 水平内边距12
    const y = bgY + 6; // 垂直内边距6
    textPainter.paint(canvas, Offset(x, y));

    // 绘制时间范围
    final timeX = bgX + 12; // 水平内边距12
    const timeY = bgY + 28; // 垂直内边距6
    timeRangePainter.paint(canvas, Offset(timeX, timeY));
  }

  /// 绘制指示器
  /// 在图表中央绘制垂直指示线
  void _drawIndicator(Canvas canvas, Size size) {
    final chartHeight = size.height -
        xAxisTitleOffset -
        xAxisTitleHeight -
        dividerPaintStyle.strokeWidth;

    // 创建指示线画笔
    final indicatorPaint = Paint()
      ..color = const Color(0xFF8186B3).withAlpha(123)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 使用传入的指示器位置
    final centerX = indicatorPosition;
    const startY = 0;
    final endY = startY + chartHeight;

    canvas.drawLine(
      Offset(centerX, startY - 1),
      Offset(centerX, endY),
      indicatorPaint,
    );
  }

  /// 绘制底部信息
  /// 显示开始时间和结束时间
  void _drawBottomInfo(Canvas canvas, Size size) {
    // 格式化日期
    final startDateStr = dateFormatter(startTime);
    final endDateStr = dateFormatter(endTime);

    // 创建日期文本画笔
    final startDatePainter = TextPainter(
      text: TextSpan(
        text: startDateStr,
        style: bottomInfoTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    final endDatePainter = TextPainter(
      text: TextSpan(
        text: endDateStr,
        style: bottomInfoTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    // 布局文本
    startDatePainter.layout();
    endDatePainter.layout();

    // 绘制日期文本
    final bottomY = size.height - xAxisTitleOffset - xAxisTitleHeight + 5;
    startDatePainter.paint(canvas, Offset(0, bottomY));
    endDatePainter.paint(
        canvas, Offset(size.width - endDatePainter.width, bottomY));
  }

  @override
  bool shouldRepaint(SleepStageChartPainter oldDelegate) {
    return oldDelegate.indicatorPosition != indicatorPosition ||
        oldDelegate.isIndicatorVisible != isIndicatorVisible;
  }
}

/// 睡眠阶段图表
/// 用于显示睡眠时长和各个阶段的详细信息
class SleepStageChart extends StatefulWidget {
  /// 睡眠详情数据
  final List<SleepStageDetails> details;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 高度单位 0 ~ 1 图表的总高度为1
  final double heightUnit;

  /// X轴底部标题偏移
  final double xAxisTitleOffset;

  /// X轴底部标题高度
  final double xAxisTitleHeight;

  /// X轴底部信息文本样式
  final TextStyle? bottomInfoTextStyle;

  /// 背景颜色
  final Color backgroundColor;

  /// 色块圆角
  final double borderRadius;

  /// 连接线宽度
  final double connectorLineWidth;

  /// 水平线样式
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直线样式
  final SleepStageChartLineStyle verticalLineStyle;

  /// 图表被水平线分为几块 默认分为8块，带上边框一共9条线
  final int horizontalLineCount;

  /// 网格线样式
  final SleepStageChartPaintStyle dividerPaintStyle;

  /// 阶段颜色映射
  final Map<SleepStageEnum, Color>? stageColors;

  /// 日期格式化函数
  final String Function(DateTime)? dateFormatter;

  /// 是否显示垂直线
  final bool showVerticalLine;

  /// 是否显示水平线
  final bool showHorizontalLine;

  /// 是否显示指示器
  final bool hasIndicator;

  /// 当指示器移动到不同色块时的回调函数
  final void Function(SleepStageDetails)? onIndicatorMoved;

  const SleepStageChart({
    super.key,
    required this.details,
    required this.startTime,
    required this.endTime,
    required this.heightUnit,
    required this.xAxisTitleOffset,
    required this.xAxisTitleHeight,
    required this.backgroundColor,
    this.borderRadius = 8.0,
    this.connectorLineWidth = 2.0,
    this.horizontalLineStyle =
        const SleepStageChartLineStyle(width: 5.0, space: 3.0),
    this.verticalLineStyle =
        const SleepStageChartLineStyle(width: 5.0, space: 3.0),
    this.horizontalLineCount = 8,
    this.dividerPaintStyle = const SleepStageChartPaintStyle(
      color: Color(0xFFEEEEEE),
      strokeWidth: 1.0,
      style: PaintingStyle.stroke,
      strokeCap: StrokeCap.round,
    ),
    this.stageColors,
    this.bottomInfoTextStyle,
    this.dateFormatter,
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.hasIndicator = true,
    this.onIndicatorMoved,
  });

  @override
  State<SleepStageChart> createState() => _SleepStageChartState();
}

/// 睡眠时长图表组件状态类，管理图表的交互状态和指示器位置
class _SleepStageChartState extends State<SleepStageChart> {
  /// 指示器位置
  double _indicatorPosition = 0.0;

  /// 是否首次初始化
  bool _isFirstInit = true;

  /// 指示器是否可见
  bool _isIndicatorVisible = false;

  /// 当前指示器所在的睡眠阶段
  SleepStageDetails? _currentStage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 首次初始化时设置指示器位置为中间
        if (_isFirstInit) {
          _indicatorPosition = constraints.maxWidth / 2;
          _isFirstInit = false;
        }

        return GestureDetector(
          // 点击时显示指示器
          onTapDown: widget.hasIndicator
              ? (details) {
                  setState(() {
                    _isIndicatorVisible = true;
                    _indicatorPosition = details.localPosition.dx
                        .clamp(0.0, constraints.maxWidth);
                    _checkCurrentStage(constraints.maxWidth);
                  });
                }
              : null,
          // 开始水平拖动
          onHorizontalDragStart: widget.hasIndicator
              ? (details) {
                  setState(() {
                    _isIndicatorVisible = true;
                    _indicatorPosition = details.localPosition.dx
                        .clamp(0.0, constraints.maxWidth);
                    _checkCurrentStage(constraints.maxWidth);
                  });
                }
              : null,
          // 水平拖动更新
          onHorizontalDragUpdate: widget.hasIndicator
              ? (details) {
                  setState(() {
                    _indicatorPosition = (_indicatorPosition + details.delta.dx)
                        .clamp(0.0, constraints.maxWidth);
                    _checkCurrentStage(constraints.maxWidth);
                  });
                }
              : null,
          // 结束水平拖动
          onHorizontalDragEnd: widget.hasIndicator
              ? (details) {
                  // 拖动结束后隐藏指示器
                  setState(() {
                    _isIndicatorVisible = false;
                  });
                }
              : null,
          // 点击结束时隐藏指示器（可选，取决于是否希望点击后指示器保持显示）
          onTapUp: widget.hasIndicator
              ? (details) {
                  // 如果希望点击后指示器消失，取消下面的注释
                  setState(() {
                    _isIndicatorVisible = false;
                  });
                }
              : null,
          child: CustomPaint(
            painter: SleepStageChartPainter(
              heightUnit: widget.heightUnit,
              xAxisTitleOffset: widget.xAxisTitleOffset,
              xAxisTitleHeight: widget.xAxisTitleHeight,
              backgroundColor: widget.backgroundColor,
              details: widget.details,
              startTime: widget.startTime,
              endTime: widget.endTime,
              borderRadius: widget.borderRadius,
              connectorLineWidth: widget.connectorLineWidth,
              horizontalLineStyle: widget.horizontalLineStyle,
              verticalLineStyle: widget.verticalLineStyle,
              horizontalLineCount: widget.horizontalLineCount,
              dividerPaintStyle: widget.dividerPaintStyle,
              stageColors: widget.stageColors,
              bottomInfoTextStyle: widget.bottomInfoTextStyle,
              dateFormatter: widget.dateFormatter,
              indicatorPosition: _indicatorPosition,
              showHorizontalLine: widget.showHorizontalLine,
              showVerticalLine: widget.showVerticalLine,
              hasIndicator: widget.hasIndicator,
              isIndicatorVisible: _isIndicatorVisible,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }

  /// 检查当前指示器所在的睡眠阶段，并在变化时触发回调
  void _checkCurrentStage(double parentWidth) {
    if (!widget.hasIndicator || widget.details.isEmpty) return;

    final totalDurationInSeconds =
        widget.endTime.difference(widget.startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = parentWidth / totalDurationInSeconds;
    SleepStageDetails? newStage;

    for (int i = 0; i < widget.details.length; i++) {
      final detail = widget.details[i];
      final barLeft = detail.startTime.difference(widget.startTime).inSeconds *
          pixelsPerSecond;
      final barWidth = detail.endTime.difference(detail.startTime).inSeconds *
          pixelsPerSecond;
      final barRight = barLeft + barWidth;

      if (_indicatorPosition >= barLeft && _indicatorPosition <= barRight) {
        newStage = detail;
        break;
      }
    }

    // 如果阶段发生变化
    if (newStage != null && newStage != _currentStage) {
      // 回调函数不为空，则触发回调
      if (widget.onIndicatorMoved != null) {
        widget.onIndicatorMoved!(newStage);
      }
    }

    _currentStage = newStage;
  }
}
