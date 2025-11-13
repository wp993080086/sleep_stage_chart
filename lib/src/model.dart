import 'dart:ui';

/// 睡眠阶段枚举，用于标识不同的睡眠状态
enum SleepStageEnum {
  /// 浅睡
  light,

  /// 深睡
  deep,

  /// 清醒
  awake,

  /// 快速眼动
  rem,

  /// 其他未知状态
  unknown,
}

/// 定义一个 Map，用于存储不同睡眠阶段 (SleepStageEnum) 对应的固定颜色
final Map<SleepStageEnum, Color> stageColors = {
  SleepStageEnum.light: const Color(0xFF54B0FF), // 浅睡阶段
  SleepStageEnum.deep: const Color(0xFF4D58E7), // 深睡阶段
  SleepStageEnum.rem: const Color(0xFF82DDDD), // REM(快速眼动)阶段
  SleepStageEnum.awake: const Color(0xFFFFA877), // 清醒阶段
};

/// 睡眠阶段图表数据详情类 用于存储图表绘制所需的睡眠阶段详细信息
class SleepStageDetails {
  /// 睡眠阶段类型
  final SleepStageEnum model;

  /// 阶段开始时间
  final DateTime startTime;

  /// 阶段结束时间
  final DateTime endTime;

  /// 详情信息
  final List<String> info;

  SleepStageDetails({
    required this.model,
    required this.startTime,
    required this.endTime,
    required this.info,
  });

  /// 创建测试用的睡眠详情图表数据
  factory SleepStageDetails.withTest() {
    return SleepStageDetails(
      model: SleepStageEnum.light,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(minutes: 30)),
      info: const [],
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

/// 从睡眠阶段枚举获取对应的mode值，用于日志显示和与原生端通信
int getModeByStage(SleepStageEnum stage) {
  switch (stage) {
    case SleepStageEnum.light:
      return 1;
    case SleepStageEnum.deep:
      return 2;
    case SleepStageEnum.awake:
      return 3;
    case SleepStageEnum.rem:
      return 4;
    case SleepStageEnum.unknown:
      return 0;
  }
}

/// 获取睡眠阶段在图表中的高度值，用于确定不同睡眠阶段在图表中的显示高度
int getHeightByStage(SleepStageEnum stage) {
  switch (stage) {
    case SleepStageEnum.deep:
      return 6;
    case SleepStageEnum.light:
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
