import 'dart:ui';

/// 睡眠阶段枚举，用于标识不同的睡眠状态
enum SleepStageEnum {
  /// 在床上
  inBed,

  /// 未知状态
  unknown,

  /// 浅睡
  core,

  /// 清醒
  awake,

  /// 深睡
  deep,

  /// 快速眼动
  rem,
}

/// 为睡眠阶段枚举添加扩展
extension SleepStageEnumExtension on SleepStageEnum {
  /// 阶段枚举对应的标题描述
  String get title {
    switch (this) {
      case SleepStageEnum.inBed:
        return '在床上';
      case SleepStageEnum.unknown:
        return '未知状态';
      case SleepStageEnum.core:
        return '浅睡';
      case SleepStageEnum.awake:
        return '清醒';
      case SleepStageEnum.deep:
        return '深睡';
      case SleepStageEnum.rem:
        return '快速眼动';
    }
  }

  /// 阶段枚举对应的苹果健康`HKCategoryValueSleepAnalysis`值
  int get healthKitValue {
    switch (this) {
      /// 在床上
      case SleepStageEnum.inBed:
        return 0;

      /// 未知状态
      case SleepStageEnum.unknown:
        return 1;

      /// 清醒
      case SleepStageEnum.awake:
        return 2;

      /// 浅睡
      case SleepStageEnum.core:
        return 3;

      /// 深睡
      case SleepStageEnum.deep:
        return 4;

      /// 快速眼动
      case SleepStageEnum.rem:
        return 5;
    }
  }
}

/// 不同睡眠阶段类型对应的颜色
final Map<SleepStageEnum, Color> sleepStageColorsMap = {
  /// 清醒阶段
  SleepStageEnum.awake: const Color(0xFFFFA877),

  /// 浅睡阶段
  SleepStageEnum.core: const Color(0xFF54B0FF),

  /// 深睡阶段
  SleepStageEnum.deep: const Color(0xFF4D58E7),

  /// 快速眼动阶段
  SleepStageEnum.rem: const Color(0xFF82DDDD),
};

/// 睡眠阶段图表数据详情类 用于存储图表绘制所需的睡眠阶段详细信息
class SleepStageDetails {
  /// 睡眠阶段类型
  final SleepStageEnum type;

  /// 阶段开始时间
  final DateTime start;

  /// 阶段结束时间
  final DateTime end;

  /// 主标题
  final List<String> titles;

  /// 副标题
  final List<String> subtitles;

  SleepStageDetails({
    required this.type,
    required this.start,
    required this.end,
    this.titles = const [],
    this.subtitles = const [],
  });

  /// 创建测试用的睡眠详情图表数据;
  factory SleepStageDetails.withTest() {
    return SleepStageDetails(
      type: SleepStageEnum.core,
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(minutes: 30)),
      titles: const [],
    );
  }
}

/// 线条样式类，定义网格线的宽度和间距
class SleepStageChartLineStyle {
  /// 线条宽度
  final double width;

  /// 线条间距
  final double space;

  const SleepStageChartLineStyle({
    required this.width,
    required this.space,
  });
}

/// 画笔样式类，定义画笔的颜色、宽度、样式和端点形状
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

/// 获取睡眠阶段在图表中的层级值，用于确定不同睡眠阶段在图表中的显示层级;
int getHierarchyByStageType(SleepStageEnum stage) {
  switch (stage) {
    case SleepStageEnum.deep:
      return 6;
    case SleepStageEnum.core:
      return 4;
    case SleepStageEnum.rem:
      return 2;
    case SleepStageEnum.awake:
      return 1;
    default:
      return 7;
  }
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
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;

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
