import 'dart:ui';

/// 睡眠阶段枚举，用于标识不同的睡眠状态
enum SleepStageTypeEnum {
  /// 在床上
  inBed,

  /// 清醒
  awake,

  /// 快速眼动
  rem,

  /// 浅睡
  core,

  /// 深睡
  deep,

  /// 未知状态
  unknown,
}

/// 为睡眠阶段枚举添加扩展
extension SleepStageEnumExtension on SleepStageTypeEnum {
  /// 阶段枚举对应的标题描述
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

  /// 阶段枚举对应的苹果健康`HKCategoryValueSleepAnalysis`值
  int get healthKitValue {
    switch (this) {
      /// 在床上
      case SleepStageTypeEnum.inBed:
        return 0;

      /// 清醒
      case SleepStageTypeEnum.awake:
        return 2;

      /// 快速眼动
      case SleepStageTypeEnum.rem:
        return 5;

      /// 浅睡
      case SleepStageTypeEnum.core:
        return 3;

      /// 深睡
      case SleepStageTypeEnum.deep:
        return 4;

      /// 未知状态
      case SleepStageTypeEnum.unknown:
        return 1;
    }
  }
}

/// 不同睡眠阶段类型对应的颜色
final Map<SleepStageTypeEnum, Color> defaultSleepStageColorsMap = {
  /// 清醒阶段
  SleepStageTypeEnum.awake: const Color(0xFFFFA877),

  /// 浅睡阶段
  SleepStageTypeEnum.core: const Color(0xFF54B0FF),

  /// 深睡阶段
  SleepStageTypeEnum.deep: const Color(0xFF4D58E7),

  /// 快速眼动阶段
  SleepStageTypeEnum.rem: const Color(0xFF82DDDD),

  /// 未知状态
  SleepStageTypeEnum.unknown: const Color(0xFFD9D9D9),
};

/// 睡眠阶段图表片段类 用于存储图表绘制所需的睡眠阶段详细信息
class SleepStageChartSegment {
  /// 阶段类型
  final SleepStageTypeEnum type;

  /// 阶段开始时间
  final DateTime start;

  /// 阶段结束时间
  final DateTime end;

  /// 主标题
  final List<String> titles;

  /// 副标题
  final List<String> subtitles;

  SleepStageChartSegment({
    required this.type,
    required this.start,
    required this.end,
    this.titles = const [],
    this.subtitles = const [],
  });

  /// 创建测试用的睡眠详情图表数据;
  factory SleepStageChartSegment.withTest() {
    return SleepStageChartSegment(
      type: SleepStageTypeEnum.core,
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(minutes: 30)),
      titles: const [],
      subtitles: const [],
    );
  }
}

/// 睡眠阶段图表线条样式类，定义网格线的宽度和间距
class SleepStageChartLineStyle {
  /// 线条宽度
  final double width;

  /// 线条间距
  final double space;

  /// 线条颜色
  final Color color;

  const SleepStageChartLineStyle({
    required this.width,
    required this.space,
    required this.color,
  });
}

/// 睡眠阶段图表画笔样式类，定义画笔的颜色,宽度,样式,端点形状
class SleepStageChartPaintStyle {
  /// 画笔颜色
  final Color color;

  /// 线条宽度
  final double strokeWidth;

  /// 绘制样式
  final PaintingStyle style;

  /// 线条端点形状
  final StrokeCap strokeCap;

  const SleepStageChartPaintStyle({
    required this.color,
    required this.strokeWidth,
    required this.style,
    required this.strokeCap,
  });
}

/// 默认线条样式
const defaultLineStyle = SleepStageChartLineStyle(
  width: 1.0,
  space: 0.0,
  color: Color(0xFFCCCCCC),
);

/// 默认睡眠阶段顺序（从上到下）
const List<SleepStageTypeEnum> defaultStageOrder = [
  SleepStageTypeEnum.awake,
  SleepStageTypeEnum.core,
  SleepStageTypeEnum.rem,
  SleepStageTypeEnum.deep,
];

/// 格式化日期（将 DateTime 对象格式化成 yyyy-MM-dd HH:mm 格式）
String formatTimeToYYYYMMDDHHMM(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

/// 格式化时间（将 DateTime 对象格式化成 HH:mm（小时:分钟）格式）
String formatTimeToHHMM(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// 格式化分钟（总分钟数 格式化成 1h23m这种格式）
String formatTimeMinute(int totalMinutes) {
  // 处理小于等于0的特殊情况
  if (totalMinutes <= 0) {
    return '0m';
  }

  // 计算小时和分钟
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;

  // 当小时为0时（即不足1小时），这个判断会直接进入最后的 else 分支
  if (hours > 0 && minutes > 0) {
    // 同时有小时和分钟
    return '${hours}h${minutes}m';
  } else if (hours > 0) {
    // 只有小时（分钟为0）
    return '${hours}h';
  } else {
    // 只有分钟（小时为0）
    return '${minutes}m';
  }
}
