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

  /// 每个阶段高度比例 0.0 ~ 0.25 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageHeightRatio;

  /// 每个阶段色块垂直间隔比例 0.0 ~ 1.0 （图表的总高度为 容器总高度-水平轴底部高度 = 1.0）
  final double stageVerticalGapRatio;

  /// 背景颜色
  final Color backgroundColor;

  /// 色块圆角，默认 8.0
  final double borderRadius;

  /// 色块连接线宽度，默认 1.0
  final double connectorLineWidth;

  /// 水平线样式，默认 defaultLineStyle
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直线样式，默认 defaultLineStyle
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平轴节点 0.0 ~ 1.0，默认 []
  final List<double> horizontalNodes;

  /// 垂直轴节点 0.0 ~ 1.0，默认 []
  final List<double> verticalNodes;

  /// 是否显示垂直线，默认 true
  final bool verticalLineVisible;

  /// 是否显示水平线，默认 true
  final bool horizontalLineVisible;

  /// 是否包含Tooltip，默认 true
  final bool hasTooltip;

  /// 是否包含Tooltip的指示器，默认 true
  final bool hasTooltipIndicator;

  /// 一整天模式，默认 false
  final bool allDayMode;

  /// 整天模式下的色块颜色,默认 #43CAC4
  final Color? allDayColor;

  /// Tooltip 垂直位置偏移（正数凸出顶部，负数距离顶部），默认 0.0
  final double tooltipOffset;

  /// Tooltip 内边距，默认 EdgeInsets.only(left: 12, top: 6, right: 12, bottom: 6)
  final EdgeInsetsGeometry? tooltipPadding;

  /// 水平轴底部高度，默认 40.0
  final double footerHeight;

  /// 水平轴子组件集合，默认 []
  final List<Widget> footerChild;

  /// 阶段颜色映射
  final Map<SleepStageTypeEnum, Color>? stageColors;

  /// 睡眠阶段顺序（从上到下），默认 [awake, core, rem, deep]
  final List<SleepStageTypeEnum>? stageOrder;

  /// 日期格式化函数
  final String Function(DateTime)? dateFormatter;

  /// 阶段名称格式化函数，用于将 SleepStageTypeEnum 转换为显示文本
  final String Function(SleepStageTypeEnum)? stageNameFormatter;

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
    this.borderRadius = 8.0,
    this.connectorLineWidth = 1.0,
    this.horizontalLineStyle = defaultLineStyle,
    this.verticalLineStyle = defaultLineStyle,
    this.verticalLineVisible = true,
    this.horizontalLineVisible = true,
    this.verticalNodes = const [],
    this.horizontalNodes = const [],
    this.hasTooltip = true,
    this.hasTooltipIndicator = true,
    this.allDayMode = false,
    this.allDayColor = const Color(0xFF43CAC4),
    this.tooltipOffset = 0.0,
    this.tooltipPadding,
    this.footerHeight = 40.0,
    this.footerChild = const [],
    this.stageColors,
    this.stageOrder,
    this.dateFormatter,
    this.stageNameFormatter,
    this.onChange,
    this.onMove,
    this.onLongPress,
    this.onClickStage,
  })  : assert(stageHeightRatio > 0 && stageHeightRatio <= 0.25,
            'stageHeightRatio 必须在 (0, 0.25] 范围内，因为 4 × stageHeightRatio ≤ 1.0'),
        assert(stageVerticalGapRatio >= 0, 'stageVerticalGapRatio 必须 ≥ 0'),
        assert(
          (stageHeightRatio * 4) + (stageVerticalGapRatio * 3) <= 1.0,
          'stageHeightRatio × 4 + stageVerticalGapRatio × 3 不能超过 1.0，'
          '当前值为 ${(stageHeightRatio * 4) + (stageVerticalGapRatio * 3)}',
        );

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
              final double maxH = constraints.maxHeight;

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

                /// 图表绘制（使用 Stack 叠加 Tooltip）
                /// 使用 OverflowBox 包裹 Stack，允许 Tooltip 超出边界
                child: Stack(
                  clipBehavior: Clip.none, // 允许子组件超出边界
                  children: [
                    // 底层：图表（使用 ClipRect 裁剪，防止图表超出）
                    ClipRect(
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
                          verticalNodes: widget.verticalNodes,
                          horizontalNodes: widget.horizontalNodes,
                          stageColors: widget.stageColors,
                          stageOrder: widget.stageOrder,
                          allDayMode: widget.allDayMode,
                          allDayColor: widget.allDayColor,
                        ),
                        size: Size(constraints.maxWidth, maxH),
                      ),
                    ),
                    // 上层：指示器和 Tooltip（仅在启用且可见时显示）
                    if (widget.hasTooltipIndicator &&
                        _isIndicatorVisible &&
                        _currentStage != null)
                      _buildTooltip(constraints.maxWidth, maxH),
                  ],
                ),
              );
            },
          ),
        ),

        /// 底部信息
        if (widget.footerChild.isNotEmpty)
          Container(
            height: widget.footerHeight,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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

  /// 构建 Tooltip Widget
  Widget _buildTooltip(double parentWidth, double parentHeight) {
    final stage = _currentStage!;

    // 计算总时间跨度
    final totalDurationInSeconds =
        widget.dateTo.difference(widget.dateFrom).inSeconds;
    if (totalDurationInSeconds <= 0) return const SizedBox.shrink();

    // 计算每秒对应的像素数
    final pixelsPerSecond = parentWidth / totalDurationInSeconds;

    // 计算当前色块的位置和宽度
    final barLeft =
        stage.start.difference(widget.dateFrom).inSeconds * pixelsPerSecond;
    final barWidth =
        stage.end.difference(stage.start).inSeconds * pixelsPerSecond;

    // 计算 Tooltip Y 坐标，应用 tooltipOffset
    // 正数 = 凸出顶部（向上偏移），负数 = 距离顶部（向下偏移）
    final bgY = -widget.tooltipOffset;

    // 获取阶段名称
    String stageName;
    if (stage.titles.isNotEmpty) {
      stageName = stage.titles.join();
    } else if (widget.stageNameFormatter != null) {
      stageName = widget.stageNameFormatter!(stage.type);
    } else {
      stageName = _getDefaultStageName(stage.type);
    }

    // 格式化时间段和持续时长
    final scopeText =
        '${formatTimeToHHMM(stage.start)}~${formatTimeToHHMM(stage.end)}';
    final durationSec = stage.end.difference(stage.start).inSeconds;
    final durationMin = (durationSec / 60).ceil();
    final durationText = formatTimeMinute(durationMin);

    // 获取 Tooltip 背景颜色
    final Color stageColor;
    if (widget.allDayMode) {
      stageColor = widget.allDayColor ??
          widget.stageColors?[SleepStageTypeEnum.unknown] ??
          Colors.grey;
    } else {
      stageColor = widget.stageColors?[stage.type] ??
          defaultSleepStageColorsMap[stage.type] ??
          Colors.grey;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// 指示器
        Positioned(
          left: _indicatorPosition,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: const Color(0xFF8186B3).withAlpha(123),
          ),
        ),

        /// Tooltip - 使用 IntrinsicWidth 获取实际宽度进行边界调整
        Positioned(
          left: 0,
          top: bgY,
          child: _TooltipPositioner(
            barLeft: barLeft,
            barWidth: barWidth,
            parentWidth: parentWidth,
            stageColor: stageColor,
            durationText: durationText,
            stageName: stageName,
            scopeText: scopeText,
            tooltipPadding: widget.tooltipPadding,
          ),
        ),
      ],
    );
  }

  /// 获取默认的阶段名称
  String _getDefaultStageName(SleepStageTypeEnum type) {
    switch (type) {
      case SleepStageTypeEnum.core:
        return '浅睡';
      case SleepStageTypeEnum.deep:
        return '深睡';
      case SleepStageTypeEnum.rem:
        return '快速眼动';
      case SleepStageTypeEnum.awake:
        return '清醒';
      case SleepStageTypeEnum.unknown:
        return '未知';
      case SleepStageTypeEnum.inBed:
        return '在床上';
    }
  }
}

/// Tooltip 定位组件
/// 用于自适应计算 Tooltip 宽度和位置
class _TooltipPositioner extends StatefulWidget {
  final double barLeft;
  final double barWidth;
  final double parentWidth;
  final Color stageColor;
  final String durationText;
  final String stageName;
  final String scopeText;
  final EdgeInsetsGeometry? tooltipPadding;

  const _TooltipPositioner({
    required this.barLeft,
    required this.barWidth,
    required this.parentWidth,
    required this.stageColor,
    required this.durationText,
    required this.stageName,
    required this.scopeText,
    this.tooltipPadding,
  });

  @override
  State<_TooltipPositioner> createState() => _TooltipPositionerState();
}

class _TooltipPositionerState extends State<_TooltipPositioner> {
  final GlobalKey _tooltipKey = GlobalKey();
  double _tooltipWidth = 0;

  @override
  void initState() {
    super.initState();
    // 在下一帧测量 Tooltip 宽度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTooltip();
    });
  }

  @override
  void didUpdateWidget(_TooltipPositioner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 内容变化时重新测量
    if (oldWidget.durationText != widget.durationText ||
        oldWidget.stageName != widget.stageName ||
        oldWidget.scopeText != widget.scopeText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureTooltip();
      });
    }
  }

  void _measureTooltip() {
    final renderBox =
        _tooltipKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      setState(() {
        _tooltipWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算 Tooltip 理想中心位置（基于色块中心）
    final idealCenterX = widget.barLeft + (widget.barWidth / 2);

    // 计算 Tooltip 的左边界和右边界（假设居中）
    final halfWidth = _tooltipWidth / 2;
    final left = idealCenterX - halfWidth;
    final right = idealCenterX + halfWidth;

    // 计算左边距
    double leftPadding;
    if (_tooltipWidth == 0) {
      // 首次渲染，先居中
      leftPadding = idealCenterX;
    } else if (left < 0) {
      // 超出左边界，贴左边
      leftPadding = 0;
    } else if (right > widget.parentWidth) {
      // 超出右边界，贴右边
      leftPadding = widget.parentWidth - _tooltipWidth;
    } else {
      // 在边界内，居中显示
      leftPadding = left;
    }

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: UnconstrainedBox(
        child: Container(
          key: _tooltipKey,
          decoration: BoxDecoration(
            color: widget.stageColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: widget.tooltipPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.durationText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.stageName} ${widget.scopeText}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
