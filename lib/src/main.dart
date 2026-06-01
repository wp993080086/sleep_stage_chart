import 'package:flutter/material.dart';
import 'model.dart';
import 'painter.dart';

/// 睡眠阶段图表
/// 用于显示睡眠时长和各个阶段的详细信息
class SleepStageChart extends StatefulWidget {
  /// 睡眠阶段数据
  final List<SleepStageChartSegment> data;

  /// 起始日期
  final DateTime dateFrom;

  /// 截至日期
  final DateTime dateTo;

  /// 每个阶段高度比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageHeightRatio;

  /// 每个阶段色块垂直间隔比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageVerticalGapRatio;

  /// 背景颜色
  final Color backgroundColor;

  /// 色块圆角
  final double borderRadius;

  /// 色块连接线宽度
  final double connectorLineWidth;

  /// 水平线样式
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直线样式
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平轴节点 0.0 ~ 1.0
  final List<double> horizontalNodes;

  /// 垂直轴节点 0.0 ~ 1.0
  final List<double> verticalNodes;

  /// 是否显示垂直线
  final bool verticalLineVisible;

  /// 是否显示水平线
  final bool horizontalLineVisible;

  /// 是否包含Tooltip
  final bool hasTooltip;

  /// 是否包含Tooltip的指示器
  final bool hasTooltipIndicator;

  /// 一整天模式 默认false
  final bool allDayMode;

  /// 水平轴底部高度
  final double footerHeight;

  /// 水平轴子组件集合
  final List<Widget> footerChild;

  /// 阶段颜色映射
  final Map<SleepStageTypeEnum, Color>? stageColors;

  /// 睡眠阶段顺序（从上到下），默认 [awake, core, rem, deep]
  final List<SleepStageTypeEnum> stageOrder;

  /// 日期格式化函数
  final String Function(DateTime)? dateFormatter;

  /// 回调函数：当指示器指向的阶段发生变化时调用
  final void Function(SleepStageChartSegment)? onChange;

  /// 回调函数：当指示器移动时调用
  final void Function(SleepStageChartSegment)? onMove;

  /// 回调函数：当长按指示器时调用
  final void Function(SleepStageChartSegment)? onLongPress;

  /// 回调函数：当点击指示器时调用
  final void Function(SleepStageChartSegment)? onClickStage;

  const SleepStageChart({
    super.key,
    required this.data,
    required this.dateFrom,
    required this.dateTo,
    required this.stageHeightRatio,
    required this.stageVerticalGapRatio,
    required this.backgroundColor,
    this.borderRadius = 4.0,
    this.connectorLineWidth = 1.0,
    this.horizontalLineStyle = defaultLineStyle,
    this.verticalLineStyle = defaultLineStyle,
    this.verticalLineVisible = true,
    this.horizontalLineVisible = true,
    this.verticalNodes = const [],
    this.horizontalNodes = const [0.0, 0.25, 0.5, 0.75, 1.0],
    this.hasTooltip = true,
    this.hasTooltipIndicator = true,
    this.allDayMode = false,
    this.footerHeight = 40.0,
    this.footerChild = const [],
    this.stageColors,
    this.stageOrder = const [
      SleepStageTypeEnum.awake,
      SleepStageTypeEnum.core,
      SleepStageTypeEnum.rem,
      SleepStageTypeEnum.deep,
    ],
    this.dateFormatter,
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
  SleepStageChartSegment? _currentStage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 图表区域
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              /// 计算容器高度
              final double maxH = widget.footerChild.isEmpty
                  ? constraints.maxHeight
                  : constraints.maxHeight - widget.footerHeight;

              /// 首次初始化时设置指示器位置为中间
              if (_isFirstInit) {
                _indicatorPosition = constraints.maxWidth / 2;
                _isFirstInit = false;
              }

              return GestureDetector(
                /// 点击时显示指示器
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

                /// 开始水平拖动
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

                /// 水平拖动更新
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

                /// 结束水平拖动
                onHorizontalDragEnd: widget.hasTooltipIndicator
                    ? (details) {
                        // 拖动结束后隐藏指示器
                        setState(() {
                          _isIndicatorVisible = false;
                        });
                      }
                    : null,

                /// 点击结束时隐藏指示器（可选，取决于是否希望点击后指示器保持显示）
                onTapUp: widget.hasTooltipIndicator
                    ? (details) {
                        // 如果希望点击后指示器消失，取消下面的注释
                        setState(() {
                          _isIndicatorVisible = false;
                        });
                      }
                    : null,

                /// 图表绘制
                child: CustomPaint(
                  painter: SleepStageChartPainter(
                    stageHeightRatio: widget.stageHeightRatio,
                    stageVerticalGapRatio: widget.stageVerticalGapRatio,
                    backgroundColor: widget.backgroundColor,
                    data: widget.data,
                    startTime: widget.dateFrom,
                    endTime: widget.dateTo,
                    borderRadius: widget.borderRadius,
                    connectorLineWidth: widget.connectorLineWidth,
                    horizontalLineStyle: widget.horizontalLineStyle,
                    verticalLineStyle: widget.verticalLineStyle,
                    stageColors: widget.stageColors,
                    stageOrder: widget.stageOrder,
                    dateFormatter: widget.dateFormatter,
                    indicatorPosition: _indicatorPosition,
                    horizontalLineVisible: widget.horizontalLineVisible,
                    verticalLineVisible: widget.verticalLineVisible,
                    hasIndicator: widget.hasTooltipIndicator,
                    indicatorVisible: _isIndicatorVisible,
                    allDayMode: widget.allDayMode,
                  ),
                  size: Size(constraints.maxWidth, maxH),
                ),
              );
            },
          ),
        ),

        /// 底部信息
        if (widget.footerChild.isNotEmpty)
          SizedBox(
            height: widget.footerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.footerChild,
            ),
          ),
      ],
    );
  }

  /// 检查当前指示器所在的睡眠阶段，并在变化时触发回调
  void _checkCurrentStage(double parentWidth) {
    if (!widget.hasTooltipIndicator || widget.data.isEmpty) return;

    final totalDurationInSeconds =
        widget.dateTo.difference(widget.dateFrom).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = parentWidth / totalDurationInSeconds;
    SleepStageChartSegment? newStage;

    for (int i = 0; i < widget.data.length; i++) {
      final detail = widget.data[i];
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

    /// 如果阶段发生变化
    if (newStage != null && newStage != _currentStage) {
      // 回调函数不为空，则触发回调
      if (widget.onChange != null) {
        widget.onChange!(newStage);
      }
    }

    /// 更新当前阶段
    _currentStage = newStage;
  }
}
