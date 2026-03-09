import 'package:flutter/material.dart';
import 'model.dart';
import 'painter.dart';

/// 睡眠阶段图表
/// 用于显示睡眠时长和各个阶段的详细信息
class SleepStageChart extends StatefulWidget {
  /// 睡眠详情数据
  final List<SleepStageDetails> details;

  /// 起始日期
  final DateTime dateFrom;

  /// 截至日期
  final DateTime dateTo;

  /// 高度比例单位 0 ~ 1 图表的总高度为1
  final double heightUnitRatio;

  /// X轴底部标题高度
  final double xAxisBottomHeight;

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
  final bool verticalLineVisible;

  /// 是否显示水平线
  final bool horizontalLineVisible;

  /// 是否包含Tooltip
  final bool hasTooltip;

  /// 是否包含Tooltip的指示器
  final bool hasTooltipIndicator;

  /// 一整天模式 默认false
  final bool allDayModel;

  /// 一整天的分钟间隙 默认360分钟
  final int minuteInterval;

  /// 底部子组件集合
  final List<Widget> bottomChild;

  /// 回调函数：当指示器指向的阶段发生变化时调用
  final void Function(SleepStageDetails)? onChange;

  /// 回调函数：当指示器移动时调用
  final void Function(SleepStageDetails)? onMove;

  /// 回调函数：当长按指示器时调用
  final void Function(SleepStageDetails)? onLongPress;

  /// 回调函数：当点击指示器时调用
  final void Function(SleepStageDetails)? onClickStage;

  const SleepStageChart({
    super.key,
    required this.details,
    required this.dateFrom,
    required this.dateTo,
    required this.heightUnitRatio,
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
    this.dateFormatter,
    this.verticalLineVisible = true,
    this.horizontalLineVisible = true,
    this.hasTooltip = true,
    this.hasTooltipIndicator = true,
    this.allDayModel = false,
    this.minuteInterval = 360,
    this.bottomChild = const [],
    this.xAxisBottomHeight = 20,
    this.onChange,
    this.onMove,
    this.onLongPress,
    this.onClickStage,
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
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 高度
              double maxH = widget.bottomChild.isEmpty
                  ? constraints.maxHeight
                  : constraints.maxHeight - widget.xAxisBottomHeight;
              // 首次初始化时设置指示器位置为中间
              if (_isFirstInit) {
                _indicatorPosition = constraints.maxWidth / 2;
                _isFirstInit = false;
              }

              return GestureDetector(
                // 点击时显示指示器
                onTapDown: widget.hasTooltipIndicator
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
                onHorizontalDragStart: widget.hasTooltipIndicator
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
                onHorizontalDragUpdate: widget.hasTooltipIndicator
                    ? (details) {
                        setState(() {
                          _indicatorPosition =
                              (_indicatorPosition + details.delta.dx)
                                  .clamp(0.0, constraints.maxWidth);
                          _checkCurrentStage(constraints.maxWidth);
                        });
                      }
                    : null,
                // 结束水平拖动
                onHorizontalDragEnd: widget.hasTooltipIndicator
                    ? (details) {
                        // 拖动结束后隐藏指示器
                        setState(() {
                          _isIndicatorVisible = false;
                        });
                      }
                    : null,
                // 点击结束时隐藏指示器（可选，取决于是否希望点击后指示器保持显示）
                onTapUp: widget.hasTooltipIndicator
                    ? (details) {
                        // 如果希望点击后指示器消失，取消下面的注释
                        setState(() {
                          _isIndicatorVisible = false;
                        });
                      }
                    : null,
                child: CustomPaint(
                  painter: SleepStageChartPainter(
                    heightUnitRatio: widget.heightUnitRatio,
                    backgroundColor: widget.backgroundColor,
                    details: widget.details,
                    startTime: widget.dateFrom,
                    endTime: widget.dateTo,
                    borderRadius: widget.borderRadius,
                    connectorLineWidth: widget.connectorLineWidth,
                    horizontalLineStyle: widget.horizontalLineStyle,
                    verticalLineStyle: widget.verticalLineStyle,
                    horizontalLineCount: widget.horizontalLineCount,
                    dividerPaintStyle: widget.dividerPaintStyle,
                    stageColors: widget.stageColors,
                    dateFormatter: widget.dateFormatter,
                    indicatorPosition: _indicatorPosition,
                    showHorizontalLine: widget.horizontalLineVisible,
                    showVerticalLine: widget.verticalLineVisible,
                    hasIndicator: widget.hasTooltipIndicator,
                    isIndicatorVisible: _isIndicatorVisible,
                    allDayModel: widget.allDayModel,
                    minuteInterval: widget.minuteInterval,
                  ),
                  size: Size(constraints.maxWidth, maxH),
                ),
              );
            },
          ),
        ),
        // 底部信息
        if (widget.bottomChild.isNotEmpty)
          SizedBox(
            height: widget.xAxisBottomHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.bottomChild,
            ),
          ),
      ],
    );
  }

  /// 检查当前指示器所在的睡眠阶段，并在变化时触发回调
  void _checkCurrentStage(double parentWidth) {
    if (!widget.hasTooltipIndicator || widget.details.isEmpty) return;

    final totalDurationInSeconds =
        widget.dateTo.difference(widget.dateFrom).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = parentWidth / totalDurationInSeconds;
    SleepStageDetails? newStage;

    for (int i = 0; i < widget.details.length; i++) {
      final detail = widget.details[i];
      final barLeft =
          detail.start.difference(widget.dateFrom).inSeconds * pixelsPerSecond;
      final barWidth =
          detail.end.difference(detail.start).inSeconds * pixelsPerSecond;
      final barRight = barLeft + barWidth;

      if (_indicatorPosition >= barLeft && _indicatorPosition <= barRight) {
        newStage = detail;
        break;
      }
    }

    // 如果阶段发生变化
    if (newStage != null && newStage != _currentStage) {
      // 回调函数不为空，则触发回调
      if (widget.onChange != null) {
        widget.onChange!(newStage);
      }
    }

    _currentStage = newStage;
  }
}
