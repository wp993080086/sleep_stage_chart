import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:math' as math;

class SleepStageChartPainter extends CustomPainter {
  final double heightUnitRatio;
  final Color backgroundColor;
  final List<SleepStageDetails> details;
  final DateTime startTime;
  final DateTime endTime;
  final double borderRadius;
  final double connectorLineWidth;
  double indicatorPosition;
  final SleepStageChartLineStyle horizontalLineStyle;
  final SleepStageChartLineStyle verticalLineStyle;
  final int horizontalLineCount;
  final SleepStageChartPaintStyle dividerPaintStyle;
  final Map<SleepStageEnum, Color> stageColors;
  final String Function(DateTime) dateFormatter;
  final bool showVerticalLine;
  final bool showHorizontalLine;
  final bool hasIndicator;
  final bool isIndicatorVisible;
  final bool allDayModel;
  final int minuteInterval;

  static final Map<SleepStageEnum, Color> _defaultStageColors = {
    SleepStageEnum.core: const Color(0xFF54B0FF),
    SleepStageEnum.deep: const Color(0xFF4D58E7),
    SleepStageEnum.rem: const Color(0xFF82DDDD),
    SleepStageEnum.awake: const Color(0xFFFFA877),
  };

  static String _defaultDateFormatter(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  double chartHeight = 0;
  double barHeight = 0;
  double startHeight = 0;

  SleepStageChartPainter({
    required this.heightUnitRatio,
    required this.backgroundColor,
    required this.details,
    required this.startTime,
    required this.endTime,
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
    Map<SleepStageEnum, Color>? stageColors,
    String Function(DateTime)? dateFormatter,
    this.indicatorPosition = 0.0,
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.hasIndicator = true,
    this.isIndicatorVisible = false,
    this.allDayModel = false,
    this.minuteInterval = 360,
  })  : stageColors = stageColors ?? _defaultStageColors,
        dateFormatter = dateFormatter ?? _defaultDateFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    chartHeight = size.height;
    barHeight = chartHeight * heightUnitRatio;
    startHeight = chartHeight * heightUnitRatio;

    const double bottomPadding = 0.0;

    final double effectiveChartHeight =
        (chartHeight - bottomPadding) > 0 ? (chartHeight - bottomPadding) : 0;

    barHeight = effectiveChartHeight * heightUnitRatio;
    startHeight = effectiveChartHeight * heightUnitRatio;

    _drawBackground(canvas, size);
    _drawLines(canvas, size);
    _drawBarArea(canvas, size);
    if (hasIndicator && isIndicatorVisible) {
      _drawIndicator(canvas, size);
      _drawTitle(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, chartHeight), backgroundPaint);
  }

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

  void _drawHorizontalLines(Canvas canvas, Size size, Paint paint) {
    if (horizontalLineStyle.width + horizontalLineStyle.space <= 0) {
      return;
    }

    final lineSpacing = chartHeight / horizontalLineCount;

    for (int i = 0; i <= horizontalLineCount; i++) {
      final y = (i * lineSpacing);
      double startX = 0;
      while (startX < size.width) {
        final double endX =
            math.min(startX + horizontalLineStyle.width, size.width);
        canvas.drawLine(
          Offset(startX, y),
          Offset(endX, y),
          paint,
        );
        startX += horizontalLineStyle.width + horizontalLineStyle.space;
      }
    }
  }

  void _drawVerticalLines(Canvas canvas, Size size, Paint paint) {
    if (verticalLineStyle.width + verticalLineStyle.space <= 0) {
      return;
    }
    if (allDayModel) {
      final double verticalLineCount = 1440 / minuteInterval;
      final double lineSpacing = size.width / verticalLineCount;
      for (int i = 0; i <= verticalLineCount; i++) {
        final x = (i * lineSpacing);
        double startY = 0;
        while (startY < chartHeight) {
          final double endY =
              math.min(startY + verticalLineStyle.width, chartHeight);
          canvas.drawLine(
            Offset(x, startY),
            Offset(x, endY),
            paint,
          );
          startY += verticalLineStyle.width + verticalLineStyle.space;
        }
      }
      return;
    }
    double startY = 0.0;
    final endY = chartHeight;

    while (startY < endY) {
      final double safeEndY = math.min(startY + verticalLineStyle.width, endY);
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, safeEndY),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, safeEndY),
        paint,
      );
      startY += verticalLineStyle.width + verticalLineStyle.space;
    }
  }

  void _drawBarArea(Canvas canvas, Size size) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    for (int i = 1; i < details.length; i++) {
      final prevDetail = details[i - 1];
      final currentDetail = details[i];

      if (prevDetail.end == currentDetail.start) {
        final connectorLeft =
            prevDetail.end.difference(startTime).inSeconds * pixelsPerSecond;
        _drawConnectedLine(
          canvas: canvas,
          currentIndex: i,
          left: connectorLeft,
        );
      }
    }

    for (int i = 0; i < details.length; i++) {
      final detail = details[i];
      final barLeft =
          detail.start.difference(startTime).inSeconds * pixelsPerSecond;
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;

      if (barWidth <= 0) continue;

      final double endY = startHeight * getHierarchyByStageType(detail.type);
      final double startY = endY;

      final paint = Paint()
        ..color = stageColors[detail.type]!
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

  void _drawConnectedLine({
    required Canvas canvas,
    required int currentIndex,
    required double left,
  }) {
    final prevBarTopY =
        (startHeight * getHierarchyByStageType(details[currentIndex - 1].type));
    final currentBarTopY =
        (startHeight * getHierarchyByStageType(details[currentIndex].type));

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

    final prevColor =
        (stageColors[details[currentIndex - 1].type] ?? Colors.transparent)
            .withAlpha(123);
    final currentColor =
        (stageColors[details[currentIndex].type] ?? Colors.transparent)
            .withAlpha(123);

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

  void _drawTitle(Canvas canvas, Size size) {
    final totalDurationInSeconds = endTime.difference(startTime).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = size.width / totalDurationInSeconds;

    SleepStageDetails? currentStage;
    double stageStartX = 0;
    double stageWidth = 0;

    for (final detail in details) {
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
      case SleepStageEnum.core:
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

    final bgPaint = Paint()
      ..color = stageColors[currentStage.type]!
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

  void _drawIndicator(Canvas canvas, Size size) {
    final chartRealHeight = size.height - dividerPaintStyle.strokeWidth;

    final indicatorPaint = Paint()
      ..color = const Color(0xFF8186B3).withAlpha(123)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = indicatorPosition;
    const startY = 0;
    final endY = startY + chartRealHeight;

    canvas.drawLine(
      Offset(centerX, startY - 1),
      Offset(centerX, endY),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(SleepStageChartPainter oldDelegate) {
    return oldDelegate.indicatorPosition != indicatorPosition ||
        oldDelegate.isIndicatorVisible != isIndicatorVisible;
  }
}
