# Sleep Stage Chart API 文档

## 概述

`sleep_stage_chart` 是一个用于显示睡眠阶段数据的 Flutter 插件，提供了美观的可视化图表，模仿 Apple Health App 的设计风格。

## 核心组件

### SleepStageChart

主要的图表组件，用于渲染睡眠阶段数据。

#### 构造函数

```dart
SleepStageChart({
  Key? key,
  required List<SleepStageDetails> details,
  required DateTime startTime,
  required DateTime endTime,
  double heightUnit = 0.6,
  double xAxisTitleOffset = 40.0,
  double xAxisTitleHeight = 30.0,
  Color bgColor = Colors.white,
  bool hasIndicator = false,
  Function(SleepStageDetails?)? onIndicatorMoved,
  Map<SleepStageEnum, Color>? stageColors,
  TextStyle? bottomInfoTextStyle,
  String Function(DateTime)? dateFormatter,
  SleepStageChartLineStyle? lineStyle,
  SleepStageChartPaintStyle? linePaintStyle,
})
```

#### 参数说明

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `details` | `List<SleepStageDetails>` | ✅ | - | 睡眠阶段数据列表 |
| `startTime` | `DateTime` | ✅ | - | 图表开始时间 |
| `endTime` | `DateTime` | ✅ | - | 图表结束时间 |
| `heightUnit` | `double` | ❌ | `0.6` | 图表高度单位比例 |
| `xAxisTitleOffset` | `double` | ❌ | `40.0` | X轴标题偏移量 |
| `xAxisTitleHeight` | `double` | ❌ | `30.0` | X轴标题高度 |
| `bgColor` | `Color` | ❌ | `Colors.white` | 背景颜色 |
| `hasIndicator` | `bool` | ❌ | `false` | 是否显示交互指示器 |
| `onIndicatorMoved` | `Function(SleepStageDetails?)?` | ❌ | `null` | 指示器移动回调 |
| `stageColors` | `Map<SleepStageEnum, Color>?` | ❌ | `null` | 自定义睡眠阶段颜色 |
| `bottomInfoTextStyle` | `TextStyle?` | ❌ | `null` | 底部信息文本样式 |
| `dateFormatter` | `String Function(DateTime)?` | ❌ | `null` | 日期格式化函数 |
| `lineStyle` | `SleepStageChartLineStyle?` | ❌ | `null` | 线条样式配置 |
| `linePaintStyle` | `SleepStageChartPaintStyle?` | ❌ | `null` | 线条绘制样式 |

#### 使用示例

```dart
SleepStageChart(
  details: sleepData,
  startTime: DateTime(2024, 1, 1, 22, 0),
  endTime: DateTime(2024, 1, 2, 8, 0),
  heightUnit: 0.8,
  hasIndicator: true,
  onIndicatorMoved: (stage) {
    print('当前阶段: ${stage?.model}');
  },
  stageColors: {
    SleepStageEnum.deep: Colors.blue.shade800,
    SleepStageEnum.light: Colors.blue.shade400,
    SleepStageEnum.rem: Colors.cyan,
    SleepStageEnum.awake: Colors.orange,
  },
)
```

### SleepStageDetails

睡眠阶段数据模型，表示一个睡眠阶段的详细信息。

#### 构造函数

```dart
SleepStageDetails({
  required SleepStageEnum model,
  required DateTime startTime,
  required DateTime endTime,
  required int duration,
})
```

#### 参数说明

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `model` | `SleepStageEnum` | ✅ | 睡眠阶段类型 |
| `startTime` | `DateTime` | ✅ | 阶段开始时间 |
| `endTime` | `DateTime` | ✅ | 阶段结束时间 |
| `duration` | `int` | ✅ | 持续时间（分钟） |

#### 工厂构造函数

```dart
// 创建测试数据
SleepStageDetails.withTest()
```

### SleepStageEnum

睡眠阶段枚举，定义了所有可能的睡眠状态。

```dart
enum SleepStageEnum {
  light,    // 浅睡眠
  deep,     // 深睡眠
  rem,      // REM睡眠
  awake,    // 清醒
  notWorn,  // 未佩戴
  unknown,  // 未知
}
```

#### 阶段高度映射

每个睡眠阶段在图表中有不同的高度值：

- `deep`: 6 (最高)
- `light`: 4
- `rem`: 2
- `awake`: 1 (最低)
- `unknown`: 7
- `notWorn`: 0

### 样式配置类

#### SleepStageChartLineStyle

线条样式配置类，用于定义网格线的外观。

```dart
class SleepStageChartLineStyle {
  final double width;  // 线条宽度
  final double space;  // 线条间距
  
  const SleepStageChartLineStyle({
    this.width = 1.0,
    this.space = 2.0,
  });
}
```

#### SleepStageChartPaintStyle

绘制样式配置类，用于定义画笔的属性。

```dart
class SleepStageChartPaintStyle {
  final Color color;              // 颜色
  final double strokeWidth;       // 线条宽度
  final PaintingStyle style;      // 绘制样式
  final StrokeCap strokeCap;      // 线条端点样式
  
  const SleepStageChartPaintStyle({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.style = PaintingStyle.stroke,
    this.strokeCap = StrokeCap.round,
  });
}
```

## 工具函数

### 睡眠阶段相关

```dart
// 获取睡眠阶段对应的模式值
int getModeByStage(SleepStageEnum stage)

// 获取睡眠阶段在图表中的高度
double getHeightByStage(SleepStageEnum stage)
```

### 时间格式化

```dart
// 格式化时间为 HH:mm 格式
String formatTimeToHHMM(DateTime time)

// 格式化分钟数为 XhYm 格式
String formatTimeMinute(int minutes)
```

## 默认配置

### 默认颜色方案

```dart
final Map<SleepStageEnum, Color> stageColors = {
  SleepStageEnum.light: Color(0xFF54B0FF),    // 浅蓝色
  SleepStageEnum.deep: Color(0xFF4D58E7),     // 深蓝色
  SleepStageEnum.rem: Color(0xFF82DDDD),      // 青色
  SleepStageEnum.awake: Color(0xFFFFA877),    // 橙色
};
```

### 默认文本样式

```dart
final TextStyle bottomInfoTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.grey.shade600,
);
```

## 交互功能

### 指示器交互

当 `hasIndicator` 设置为 `true` 时，图表支持以下交互：

1. **点击交互**: 点击图表任意位置显示指示器
2. **拖拽交互**: 拖拽指示器到不同位置
3. **回调通知**: 通过 `onIndicatorMoved` 回调获取当前阶段信息

### 回调函数

```dart
void onIndicatorMoved(SleepStageDetails? currentStage) {
  if (currentStage != null) {
    print('当前睡眠阶段: ${currentStage.model}');
    print('开始时间: ${formatTimeToHHMM(currentStage.startTime)}');
    print('结束时间: ${formatTimeToHHMM(currentStage.endTime)}');
    print('持续时间: ${formatTimeMinute(currentStage.duration)}');
  }
}
```

## 最佳实践

### 1. 数据准备

```dart
// 确保数据按时间顺序排列
List<SleepStageDetails> sleepData = [
  SleepStageDetails(
    model: SleepStageEnum.light,
    startTime: DateTime(2024, 1, 1, 22, 30),
    endTime: DateTime(2024, 1, 1, 23, 30),
    duration: 60,
  ),
  // ... 更多数据
];

// 按开始时间排序
sleepData.sort((a, b) => a.startTime.compareTo(b.startTime));
```

### 2. 时间范围设置

```dart
// 确保时间范围覆盖所有数据
DateTime chartStart = sleepData.first.startTime;
DateTime chartEnd = sleepData.last.endTime;

// 添加一些边距
chartStart = chartStart.subtract(Duration(minutes: 30));
chartEnd = chartEnd.add(Duration(minutes: 30));
```

### 3. 自定义样式

```dart
SleepStageChart(
  details: sleepData,
  startTime: chartStart,
  endTime: chartEnd,
  // 自定义颜色
  stageColors: {
    SleepStageEnum.deep: Colors.indigo.shade800,
    SleepStageEnum.light: Colors.indigo.shade400,
    SleepStageEnum.rem: Colors.teal.shade300,
    SleepStageEnum.awake: Colors.amber.shade600,
  },
  // 自定义文本样式
  bottomInfoTextStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade700,
  ),
  // 自定义线条样式
  lineStyle: SleepStageChartLineStyle(
    width: 1.5,
    space: 3.0,
  ),
)
```

## 注意事项

1. **性能优化**: 对于大量数据，建议进行数据分页或时间范围限制
2. **时区处理**: 确保所有时间数据使用相同的时区
3. **数据验证**: 验证睡眠阶段数据的连续性和完整性
4. **内存管理**: 及时释放不需要的数据引用
5. **错误处理**: 处理空数据或异常时间范围的情况

## 故障排除

### 常见问题

1. **图表不显示**: 检查数据是否为空或时间范围是否正确
2. **颜色异常**: 确认自定义颜色映射包含所有使用的睡眠阶段
3. **交互无响应**: 检查 `hasIndicator` 是否设置为 `true`

### 调试技巧

```dart
// 打印数据信息
print('睡眠数据数量: ${sleepData.length}');
print('时间范围: ${chartStart} - ${chartEnd}');

// 验证数据完整性
for (var stage in sleepData) {
  assert(stage.startTime.isBefore(stage.endTime));
  assert(stage.duration > 0);
}
```