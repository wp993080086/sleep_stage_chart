import 'dart:ui';

import 'package:flutter/material.dart';

/// ============================================================================
/// 睡眠阶段类型枚举
/// ============================================================================

/// 睡眠阶段类型枚举
///
/// 用于标识不同的睡眠状态，包括在床上、清醒、快速眼动、浅睡、深睡和未知状态。
enum SleepStageTypeEnum {
  /// 在床上状态
  inBed,

  /// 清醒状态
  awake,

  /// 快速眼动（REM）睡眠状态
  rem,

  /// 浅睡（Core/NREM1-2）状态
  core,

  /// 深睡（Deep/NREM3）状态
  deep,

  /// 未知或未分类状态
  unknown,
}

/// ============================================================================
/// 睡眠阶段枚举扩展
/// ============================================================================

/// 为 [SleepStageTypeEnum] 提供扩展方法
///
/// 提供标题描述和 HealthKit 值转换功能。
extension SleepStageEnumExtension on SleepStageTypeEnum {
  /// 获取阶段类型对应的标题描述
  ///
  /// 返回中文描述，用于 UI 显示。
  String get title {
    switch (this) {
      case SleepStageTypeEnum.inBed:
        return '在床上';
      case SleepStageTypeEnum.awake:
        return '清醒';
      case SleepStageTypeEnum.core:
        return '浅睡';
      case SleepStageTypeEnum.rem:
        return '快速眼动';
      case SleepStageTypeEnum.deep:
        return '深睡';
      case SleepStageTypeEnum.unknown:
        return '未知状态';
    }
  }

  /// 获取阶段类型对应的 Apple HealthKit 值
  ///
  /// 对应 `HKCategoryValueSleepAnalysis` 枚举值：
  /// - 0: 在床上
  /// - 1: 睡眠中（未知）
  /// - 2: 清醒
  /// - 3: 浅睡
  /// - 4: 深睡
  /// - 5: 快速眼动
  int get healthKitValue {
    switch (this) {
      case SleepStageTypeEnum.inBed:
        return 0;
      case SleepStageTypeEnum.awake:
        return 2;
      case SleepStageTypeEnum.rem:
        return 5;
      case SleepStageTypeEnum.core:
        return 3;
      case SleepStageTypeEnum.deep:
        return 4;
      case SleepStageTypeEnum.unknown:
        return 1;
    }
  }
}

/// ============================================================================
/// 默认颜色映射
/// ============================================================================

/// 默认睡眠阶段颜色映射表
///
/// 为每种睡眠阶段类型提供默认的显示颜色。
final Map<SleepStageTypeEnum, Color> defaultSleepStageColorsMap = {
  /// 清醒阶段 - 橙色
  SleepStageTypeEnum.awake: const Color(0xFFFFA877),

  /// 浅睡阶段 - 浅蓝色
  SleepStageTypeEnum.core: const Color(0xFF54B0FF),

  /// 深睡阶段 - 深蓝色
  SleepStageTypeEnum.deep: const Color(0xFF4D58E7),

  /// 快速眼动阶段 - 青色
  SleepStageTypeEnum.rem: const Color(0xFF82DDDD),

  /// 未知状态 - 灰色
  SleepStageTypeEnum.unknown: const Color(0xFFD9D9D9),
};

/// ============================================================================
/// 睡眠阶段图表数据片段
/// ============================================================================

/// 睡眠阶段图表数据片段
///
/// 用于存储图表绘制所需的单个睡眠阶段详细信息，
/// 包括阶段类型、起止时间、标题和副标题。
class SleepStageChartSegment {
  /// 睡眠阶段类型
  final SleepStageTypeEnum type;

  /// 阶段开始时间
  final DateTime start;

  /// 阶段结束时间
  final DateTime end;

  /// 主标题列表（用于 Tooltip 显示）
  final List<String> titles;

  /// 副标题（预留字段）
  final String? subtitle;

  /// 创建睡眠阶段数据片段
  ///
  /// [type] - 阶段类型（必填）
  /// [start] - 开始时间（必填）
  /// [end] - 结束时间（必填）
  /// [titles] - 主标题列表（可选，默认为空）
  /// [subtitles] - 副标题列表（可选，默认为空）
  const SleepStageChartSegment({
    required this.type,
    required this.start,
    required this.end,
    this.titles = const [],
    this.subtitle,
  });

  /// 创建测试用的睡眠阶段数据片段
  ///
  /// 用于开发和测试场景，创建一个默认的浅睡阶段片段。
  factory SleepStageChartSegment.withTest() {
    final now = DateTime.now();
    return SleepStageChartSegment(
      type: SleepStageTypeEnum.core,
      start: now,
      end: now.add(const Duration(minutes: 30)),
    );
  }

  /// 获取阶段持续时长
  ///
  /// 返回 [end] 与 [start] 之间的时间差。
  Duration get duration => end.difference(start);

  /// 获取阶段持续分钟数
  ///
  /// 返回持续时长的分钟数（向上取整）。
  int get durationInMinutes => duration.inSeconds ~/ 60;
}

/// ============================================================================
/// 线条样式
/// ============================================================================

/// 睡眠阶段图表线条样式
///
/// 定义网格线的宽度、虚线样式和颜色。
class SleepStageChartLineStyle {
  /// 线条宽度（粗细）
  final double width;

  /// 虚线每段长度（实线部分长度）
  ///
  /// 当值为 0 时，绘制实线。
  final double dashLength;

  /// 虚线间隔（空白部分长度）
  ///
  /// 当值为 0 时，绘制实线。
  final double space;

  /// 线条颜色
  final Color color;

  /// 创建线条样式
  ///
  /// [width] - 线条宽度
  /// [dashLength] - 虚线段长度（0 表示实线）
  /// [space] - 虚线间隔（0 表示实线）
  /// [color] - 线条颜色
  const SleepStageChartLineStyle({
    required this.width,
    required this.dashLength,
    required this.space,
    required this.color,
  });

  /// 判断是否为虚线样式
  ///
  /// 当 [dashLength] 和 [space] 都大于 0 时返回 true。
  bool get isDashed => dashLength > 0 && space > 0;
}

/// 默认线条样式
///
/// 实线样式，宽度 0.5，浅灰色。
const SleepStageChartLineStyle defaultLineStyle = SleepStageChartLineStyle(
  width: 0.5,
  dashLength: 0.0,
  space: 0.0,
  color: Color(0xFFE3E3E3),
);

/// ============================================================================
/// 画笔样式
/// ============================================================================

/// 睡眠阶段图表画笔样式
///
/// 定义画笔的颜色、宽度、样式和端点形状。
class SleepStageChartPaintStyle {
  /// 画笔颜色
  final Color color;

  /// 线条宽度
  final double strokeWidth;

  /// 绘制样式（填充或描边）
  final PaintingStyle style;

  /// 线条端点形状
  final StrokeCap strokeCap;

  /// 创建画笔样式
  const SleepStageChartPaintStyle({
    required this.color,
    required this.strokeWidth,
    required this.style,
    required this.strokeCap,
  });
}

/// ============================================================================
/// 默认阶段顺序
/// ============================================================================

/// 默认睡眠阶段顺序（从上到下）
///
/// 图表中色块从上到下的排列顺序：
/// 清醒 -> 浅睡 -> 快速眼动 -> 深睡
const List<SleepStageTypeEnum> defaultStageOrder = [
  SleepStageTypeEnum.awake,
  SleepStageTypeEnum.core,
  SleepStageTypeEnum.rem,
  SleepStageTypeEnum.deep,
];

/// Tooltip默认背景颜色
const Color defaultTooltipBackgroundColor = Color(0xFFF5F5F5);

/// Tooltip默认主文字样式大
const TextStyle defaultPrimaryStyleBig = TextStyle(
  color: Colors.black,
  fontSize: 20,
  fontWeight: FontWeight.w800,
  height: 24 / 20,
);

/// Tooltip默认主文字样式小
const TextStyle defaultPrimaryStyleSmall = TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.w700,
  height: 20 / 16,
);

/// Tooltip默认副文字样式
const TextStyle defaultSecondaryStyle = TextStyle(
  color: Color(0xFF373737),
  fontSize: 13,
  fontWeight: FontWeight.w500,
  height: 18 / 13,
);

/// ============================================================================
/// 时间格式化工具函数
/// ============================================================================

/// 格式化日期时间为完整格式
///
/// 格式: MM-dd HH:mm（例如：12-25 08:30）
///
/// [date] - 要格式化的日期时间
String formatTimeToYYYYMMDDHHMM(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

/// 格式化时间为小时分钟格式
///
/// 格式: HH:mm（例如：08:30）
///
/// [time] - 要格式化的时间
String formatTimeToHHMM(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// 格式化分钟数为可读字符串
///
/// 格式规则：
/// - 大于 0 小时且有余数: XhYm（例如：1h30m）
/// - 正好 X 小时: Xh（例如：2h）
/// - 不足 1 小时: Xm（例如：45m）
/// - 小于等于 0: 0m
///
/// [totalMinutes] - 总分钟数
String formatTimeMinute(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '0m';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours > 0 && minutes > 0) {
    return '${hours}h${minutes}m';
  } else if (hours > 0) {
    return '${hours}h';
  } else {
    return '${minutes}m';
  }
}
