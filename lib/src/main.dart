import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'model.dart';
import 'painter.dart';

/// ============================================================================
/// 睡眠阶段图表组件
/// ============================================================================

/// 睡眠阶段图表组件
///
/// 用于显示睡眠时长和各个阶段的详细信息，支持：
/// - 正常模式：显示多个睡眠阶段色块，按类型分层
/// - 整天模式：显示单个居中色块，用于全天概览
/// - 交互功能：触摸显示 Tooltip 和指示器
/// - 自定义样式：颜色、网格线、阶段顺序等
///
/// 使用示例：
/// ```dart
/// SleepStageChart(
///   data: sleepData,
///   dateFrom: startTime,
///   dateTo: endTime,
///   stageHeightRatio: 0.2,
///   stageVerticalGapRatio: 0.05,
///   backgroundColor: Colors.white,
/// )
/// ```
class SleepStageChart extends StatefulWidget {
  /// ==========================================================================
  /// 构造参数 - 数据
  /// ==========================================================================

  /// 睡眠阶段数据列表
  final List<SleepStageChartSegment> data;

  /// 图表开始时间（X轴起点）
  final DateTime dateFrom;

  /// 图表结束时间（X轴终点）
  final DateTime dateTo;

  /// ==========================================================================
  /// 构造参数 - 布局
  /// ==========================================================================

  /// 单个色块高度占图表总高度的比例，范围 (0, 0.25]
  ///
  /// 限制为最大 0.25，因为 4 个色块 × 0.25 = 1.0（总高度）
  final double stageHeightRatio;

  /// 相邻色块之间的间距占图表总高度的比例，范围 [0, 1.0]
  ///
  /// 所有色块高度 + 所有间距不能超过 1.0
  final double stageVerticalGapRatio;

  /// ==========================================================================
  /// 构造参数 - 样式
  /// ==========================================================================

  /// 图表背景颜色
  final Color backgroundColor;

  /// 色块圆角半径，默认 4.0
  final double borderRadius;

  /// 相邻色块间连接线的宽度，默认 1.0
  final double connectorLineWidth;

  /// 水平网格线样式，默认 [defaultLineStyle]
  final SleepStageChartLineStyle horizontalLineStyle;

  /// 垂直网格线样式，默认 [defaultLineStyle]
  final SleepStageChartLineStyle verticalLineStyle;

  /// 水平线节点位置列表，范围 [0.0, 1.0]，默认 []
  ///
  /// 0.0 表示顶部，1.0 表示底部
  final List<double> horizontalNodes;

  /// 垂直线节点位置列表，范围 [0.0, 1.0]，默认 []
  ///
  /// 0.0 表示左侧，1.0 表示右侧
  final List<double> verticalNodes;

  /// 是否显示垂直网格线，默认 true
  final bool verticalLineVisible;

  /// 是否显示水平网格线，默认 true
  final bool horizontalLineVisible;

  /// ==========================================================================
  /// 构造参数 - Tooltip
  /// ==========================================================================

  /// 是否显示 Tooltip，默认 true
  final bool hasTooltip;

  /// 是否显示 Tooltip 的指示器（垂直线），默认 true
  final bool hasTooltipIndicator;

  /// Tooltip 垂直位置偏移，默认 0.0
  ///
  /// 正数表示向上偏移（凸出顶部），负数表示向下偏移（距离顶部）
  final double tooltipOffset;

  /// Tooltip 内边距，默认 EdgeInsets.symmetric(horizontal: 12, vertical: 6)
  final EdgeInsetsGeometry? tooltipPadding;

  /// Tooltip 背景颜色，默认使用阶段颜色
  final Color? tooltipBackgroundColor;

  /// Tooltip 圆角半径，默认 12.0
  final double tooltipBorderRadius;

  /// 主文字样式（持续时长），默认白色 16px 加粗
  final TextStyle? tooltipPrimaryTextStyleBig;

  /// 主文字样式（持续时长），默认白色 16px 加粗
  final TextStyle? tooltipPrimaryTextStyleSmall;

  /// 次文字样式（阶段名称和时间范围），默认白色 13px 中等粗细
  final TextStyle? tooltipSecondaryTextStyle;

  /// 标题是否是驼峰样式,默认true
  final bool hasTitleHump;

  /// ==========================================================================
  /// 构造参数 - 模式
  /// ==========================================================================

  /// 是否启用整天模式，默认 false
  ///
  /// 整天模式下只显示一个居中的色块，用于展示全天睡眠概览
  final bool allDayMode;

  /// 整天模式下的色块颜色，默认 Color(0xFF43CAC4)
  final Color? allDayColor;

  /// ==========================================================================
  /// 构造参数 - 阶段配置
  /// ==========================================================================

  /// 睡眠阶段颜色映射表
  ///
  /// 为每种 [SleepStageTypeEnum] 指定显示颜色
  final Map<SleepStageTypeEnum, Color>? stageColors;

  /// 睡眠阶段显示顺序（从上到下），默认 [awake, core, rem, deep]
  final List<SleepStageTypeEnum>? stageOrder;

  /// ==========================================================================
  /// 构造参数 - 底部区域
  /// ==========================================================================

  /// 底部区域高度，默认 40.0
  final double footerHeight;

  /// 底部区域子组件列表，默认 []
  final List<Widget> footerChildren;

  /// ==========================================================================
  /// 构造参数 - 回调函数
  /// ==========================================================================

  /// 当指示器指向的阶段发生变化时调用
  final void Function(SleepStageChartSegment)? onStageChanged;

  /// 当指示器移动时调用
  final void Function(SleepStageChartSegment)? onIndicatorMove;

  /// 当长按指示器时调用
  final void Function(SleepStageChartSegment)? onIndicatorLongPress;

  /// 当点击阶段色块时调用
  final void Function(SleepStageChartSegment)? onStageTap;

  /// ==========================================================================
  /// 构造函数
  /// ==========================================================================

  /// 创建睡眠阶段图表组件
  ///
  /// 必需参数：
  /// - [data] - 睡眠阶段数据
  /// - [dateFrom] - 开始时间
  /// - [dateTo] - 结束时间
  /// - [stageHeightRatio] - 色块高度比例
  /// - [stageVerticalGapRatio] - 色块间距比例
  /// - [backgroundColor] - 背景颜色
  ///
  /// 可选参数：使用默认值
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
    this.horizontalNodes = const [],
    this.hasTooltip = true,
    this.hasTooltipIndicator = true,
    this.allDayMode = false,
    this.allDayColor = const Color(0xFF43CAC4),
    this.tooltipOffset = 0.0,
    this.tooltipPadding,
    this.tooltipBackgroundColor,
    this.tooltipBorderRadius = 12.0,
    this.tooltipPrimaryTextStyleBig,
    this.tooltipPrimaryTextStyleSmall,
    this.tooltipSecondaryTextStyle,
    this.hasTitleHump = true,
    this.footerHeight = 40.0,
    this.footerChildren = const [],
    this.stageColors,
    this.stageOrder,
    this.onStageChanged,
    this.onIndicatorMove,
    this.onIndicatorLongPress,
    this.onStageTap,
  })  : assert(
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

  @override
  State<SleepStageChart> createState() => _SleepStageChartState();
}

/// ============================================================================
/// 组件状态类
/// ============================================================================

/// 睡眠阶段图表组件状态类
///
/// 管理图表的交互状态和指示器位置，包括：
/// - 指示器位置跟踪
/// - 当前阶段检测
/// - Tooltip 显示控制
class _SleepStageChartState extends State<SleepStageChart> {
  /// 指示器当前 X 坐标位置（相对于图表左边缘）
  double _indicatorPositionX = 0.0;

  /// 是否首次初始化
  bool _isFirstInitialization = true;

  /// 指示器是否可见
  bool _isIndicatorVisible = false;

  /// 当前指示器所在的睡眠阶段
  SleepStageChartSegment? _currentStage;

  /// ==========================================================================
  /// 构建方法
  /// ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图表区域
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final maxWidth = constraints.maxWidth;

              // 首次初始化时设置指示器位置为中间
              if (_isFirstInitialization) {
                _indicatorPositionX = maxWidth / 2;
                _isFirstInitialization = false;
              }

              return GestureDetector(
                // 点击时显示指示器
                onTapDown: widget.hasTooltipIndicator
                    ? (details) => _handleTapDown(details, maxWidth)
                    : null,

                // 开始水平拖动
                onHorizontalDragStart: widget.hasTooltipIndicator
                    ? (details) => _handleDragStart(details, maxWidth)
                    : null,

                // 水平拖动更新
                onHorizontalDragUpdate: widget.hasTooltipIndicator
                    ? (details) => _handleDragUpdate(details, maxWidth)
                    : null,

                // 结束水平拖动
                onHorizontalDragEnd:
                    widget.hasTooltipIndicator ? (_) => _handleDragEnd() : null,

                // 点击结束时隐藏指示器
                onTapUp:
                    widget.hasTooltipIndicator ? (_) => _handleTapUp() : null,

                child: Stack(
                  clipBehavior: Clip.none,
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
                        size: Size(maxWidth, maxHeight),
                      ),
                    ),

                    // 上层：指示器和 Tooltip
                    if (widget.hasTooltipIndicator &&
                        _isIndicatorVisible &&
                        _currentStage != null)
                      _buildTooltipOverlay(
                          maxWidth, maxHeight, widget.hasTitleHump),
                  ],
                ),
              );
            },
          ),
        ),

        // 底部信息区域
        if (widget.footerChildren.isNotEmpty) _buildFooter(),
      ],
    );
  }

  /// ==========================================================================
  /// 手势处理
  /// ==========================================================================

  /// 处理点击按下事件
  void _handleTapDown(TapDownDetails details, double maxWidth) {
    setState(() {
      _isIndicatorVisible = true;
      _indicatorPositionX = details.localPosition.dx.clamp(0.0, maxWidth);
      _updateCurrentStage(maxWidth);
    });
  }

  /// 处理拖动开始事件
  void _handleDragStart(DragStartDetails details, double maxWidth) {
    setState(() {
      _isIndicatorVisible = true;
      _indicatorPositionX = details.localPosition.dx.clamp(0.0, maxWidth);
      _updateCurrentStage(maxWidth);
    });
  }

  /// 处理拖动更新事件
  void _handleDragUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _indicatorPositionX =
          (_indicatorPositionX + details.delta.dx).clamp(0.0, maxWidth);
      _updateCurrentStage(maxWidth);
    });

    // 触发移动回调
    if (widget.onIndicatorMove != null && _currentStage != null) {
      widget.onIndicatorMove!(_currentStage!);
    }
  }

  /// 处理拖动结束事件
  void _handleDragEnd() {
    setState(() {
      _isIndicatorVisible = false;
    });
  }

  /// 处理点击抬起事件
  void _handleTapUp() {
    setState(() {
      _isIndicatorVisible = false;
    });
  }

  /// ==========================================================================
  /// 阶段检测
  /// ==========================================================================

  /// 更新当前指示器所在的睡眠阶段
  ///
  /// 根据指示器位置计算当前所在的阶段，并在阶段变化时触发回调
  void _updateCurrentStage(double parentWidth) {
    if (!widget.hasTooltipIndicator || widget.data.isEmpty) return;

    final totalDurationInSeconds =
        widget.dateTo.difference(widget.dateFrom).inSeconds;
    if (totalDurationInSeconds <= 0) return;

    final pixelsPerSecond = parentWidth / totalDurationInSeconds;
    SleepStageChartSegment? detectedStage;

    // 遍历所有阶段，检测指示器位置是否在阶段范围内
    for (final segment in widget.data) {
      final barLeft =
          segment.start.difference(widget.dateFrom).inSeconds * pixelsPerSecond;
      final barWidth =
          segment.end.difference(segment.start).inSeconds * pixelsPerSecond;
      final barRight = barLeft + barWidth;

      if (_indicatorPositionX >= barLeft && _indicatorPositionX <= barRight) {
        detectedStage = segment;
        break;
      }
    }

    // 如果阶段发生变化，触发回调
    if (detectedStage != null && detectedStage != _currentStage) {
      if (widget.onStageChanged != null) {
        widget.onStageChanged!(detectedStage);
      }
    }

    _currentStage = detectedStage;
  }

  /// ==========================================================================
  /// 底部区域构建
  /// ==========================================================================

  /// 构建底部信息区域
  Widget _buildFooter() {
    return Container(
      height: widget.footerHeight,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.footerChildren,
      ),
    );
  }

  /// ==========================================================================
  /// Tooltip 构建
  /// ==========================================================================

  /// 构建 Tooltip 覆盖层
  ///
  /// 包含指示器（垂直线）和 Tooltip 内容
  Widget _buildTooltipOverlay(
    double parentWidth,
    double parentHeight,
    bool hasTitleHump,
  ) {
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
    final tooltipTopY = -widget.tooltipOffset;

    // 获取 Tooltip 背景颜色
    final stageColor = _resolveStageColor(stage);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 指示器（垂直线）
        Positioned(
          left: _indicatorPositionX,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: const Color(0xFF8186B3).withAlpha(123),
          ),
        ),

        // Tooltip 定位组件
        Positioned(
          left: 0,
          top: tooltipTopY,
          child: _TooltipPositioner(
            hasTitleHump: hasTitleHump,
            barLeft: barLeft,
            barWidth: barWidth,
            parentWidth: parentWidth,
            stageColor: stageColor,
            primaryText: stage.titles,
            secondaryText: stage.subtitle,
            tooltipPadding: widget.tooltipPadding,
            tooltipBackgroundColor: widget.tooltipBackgroundColor,
            tooltipBorderRadius: widget.tooltipBorderRadius,
            tooltipPrimaryTextStyleBig: widget.tooltipPrimaryTextStyleBig,
            tooltipPrimaryTextStyleSmall: widget.tooltipPrimaryTextStyleSmall,
            tooltipSecondaryTextStyle: widget.tooltipSecondaryTextStyle,
          ),
        ),
      ],
    );
  }

  /// 解析阶段颜色
  ///
  /// 优先级：allDayColor > stageColors > defaultSleepStageColorsMap
  Color _resolveStageColor(SleepStageChartSegment stage) {
    if (widget.allDayMode) {
      return widget.allDayColor ??
          widget.stageColors?[SleepStageTypeEnum.unknown] ??
          Colors.grey;
    } else {
      return widget.stageColors?[stage.type] ??
          defaultSleepStageColorsMap[stage.type] ??
          Colors.grey;
    }
  }
}

/// ============================================================================
/// Tooltip 定位组件
/// ============================================================================

/// Tooltip 自适应定位组件
///
/// 根据内容宽度和图表边界自动调整 Tooltip 位置：
/// - 默认居中于色块
/// - 超出左边界时贴左
/// - 超出右边界时贴右
class _TooltipPositioner extends StatefulWidget {
  /// 标题是否是驼峰样式
  final bool hasTitleHump;

  /// 当前色块左边缘 X 坐标
  final double barLeft;

  /// 当前色块宽度
  final double barWidth;

  /// 父容器（图表）宽度
  final double parentWidth;

  /// Tooltip 背景颜色
  final Color stageColor;

  /// 主文本
  final List<String> primaryText;

  /// 副文本
  final String? secondaryText;

  /// Tooltip 内边距
  final EdgeInsetsGeometry? tooltipPadding;

  /// Tooltip 背景颜色（覆盖阶段颜色）
  final Color? tooltipBackgroundColor;

  /// Tooltip 圆角半径
  final double tooltipBorderRadius;

  /// 主文字样式大（持续时长）
  final TextStyle? tooltipPrimaryTextStyleBig;

  /// 主文字样式小（持续时长）
  final TextStyle? tooltipPrimaryTextStyleSmall;

  /// 次文字样式（阶段名称和时间范围）
  final TextStyle? tooltipSecondaryTextStyle;

  const _TooltipPositioner({
    required this.hasTitleHump,
    required this.barLeft,
    required this.barWidth,
    required this.parentWidth,
    required this.stageColor,
    required this.primaryText,
    this.secondaryText,
    this.tooltipPadding,
    this.tooltipBackgroundColor,
    required this.tooltipBorderRadius,
    this.tooltipPrimaryTextStyleBig,
    this.tooltipPrimaryTextStyleSmall,
    this.tooltipSecondaryTextStyle,
  });

  @override
  State<_TooltipPositioner> createState() => _TooltipPositionerState();
}

class _TooltipPositionerState extends State<_TooltipPositioner> {
  @override
  Widget build(BuildContext context) {
    /// 主文字样式（大）
    final primaryStyleBig =
        widget.tooltipPrimaryTextStyleBig ?? defaultPrimaryStyleBig;

    /// 主文字样式（小）
    final primaryStyleSmall =
        widget.tooltipPrimaryTextStyleSmall ?? defaultPrimaryStyleSmall;

    /// 副文字样式
    final secondaryStyle =
        widget.tooltipSecondaryTextStyle ?? defaultSecondaryStyle;

    /// 使用 TextPainter 预计算 Tooltip 宽度
    final tooltipWidth = _measureTooltipWidth(
      primaryStyleBig,
      primaryStyleSmall,
      secondaryStyle,
    );

    // 计算 Tooltip 理想中心位置（基于色块中心）
    final idealCenterX = widget.barLeft + (widget.barWidth / 2);

    // 计算左边距
    final leftPadding = _calculateLeftPadding(idealCenterX, tooltipWidth);

    // 确定背景颜色（优先级：自定义 > 阶段颜色）
    final backgroundColor =
        widget.tooltipBackgroundColor ?? defaultTooltipBackgroundColor;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: UnconstrainedBox(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.tooltipBorderRadius),
          ),
          padding: widget.tooltipPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主文字
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.primaryText.length, (index) {
                  bool isBig = true;
                  // 奇数索引为小文字
                  if (index % 2 == 1 && widget.hasTitleHump) {
                    isBig = false;
                  }
                  return Text(
                    widget.primaryText[index],
                    style: isBig ? primaryStyleBig : primaryStyleSmall,
                  );
                }),
              ),
              const SizedBox(height: 4),
              // 次文字
              if (widget.secondaryText != null)
                Text(widget.secondaryText!, style: secondaryStyle),
            ],
          ),
        ),
      ),
    );
  }

  /// 使用 TextPainter 预计算 Tooltip 宽度
  ///
  /// 计算主文字（支持驼峰效果）和次文字的宽度，取较大值加上水平内边距
  double _measureTooltipWidth(
    TextStyle primaryStyleBig,
    TextStyle primaryStyleSmall,
    TextStyle secondaryStyle,
  ) {
    final horizontalPadding = widget.tooltipPadding != null
        ? (widget.tooltipPadding as EdgeInsets).horizontal
        : 24.0; // 默认 EdgeInsets.symmetric(horizontal: 12, vertical: 6)

    // 测量主文字宽度（考虑驼峰效果：偶数索引为小文字）
    double primaryWidth = 0;
    for (var i = 0; i < widget.primaryText.length; i++) {
      final isSmall = i % 2 == 0 && widget.hasTitleHump;
      final style = isSmall ? primaryStyleSmall : primaryStyleBig;
      final painter = TextPainter(
        text: TextSpan(text: widget.primaryText[i], style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      primaryWidth += painter.width;
    }

    // 测量次文字宽度
    double secondaryWidth = 0;
    if (widget.secondaryText != null) {
      final painter = TextPainter(
        text: TextSpan(text: widget.secondaryText!, style: secondaryStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      secondaryWidth += painter.width;
    }

    // 取较大宽度加上内边距
    final maxTextWidth = math.max(primaryWidth, secondaryWidth);
    return maxTextWidth + horizontalPadding;
  }

  /// 计算 Tooltip 左边距
  ///
  /// 根据 Tooltip 宽度和图表边界计算合适的左边距：
  /// - 超出左边界：贴左（0）
  /// - 超出右边界：贴右（parentWidth - tooltipWidth）
  /// - 正常情况：居中
  double _calculateLeftPadding(double idealCenterX, double tooltipWidth) {
    final halfWidth = tooltipWidth / 2;
    final left = idealCenterX - halfWidth;
    final right = idealCenterX + halfWidth;

    // 超出左边界，贴左边
    if (left < 0) {
      return 0;
    }

    // 超出右边界，贴右边
    if (right > widget.parentWidth) {
      return widget.parentWidth - tooltipWidth;
    }

    // 在边界内，居中显示
    return left;
  }
}
