# Sleep Stage Chart API 文档

一个用于显示睡眠阶段和睡眠质量数据的可视化图表的 Flutter 插件，同时还支持冥想图表。兼容 Android、iOS 和 Windows 平台。

## 特性

- 📊 **精美的睡眠图表**: 以平滑的过渡和渐变显示睡眠阶段。
- 🎨 **可定制**: 完全控制颜色、样式和布局。
- 📱 **跨平台**: 可在 Android、iOS 和 Windows 上运行。
- 🤏 **交互式**: 通过触摸和拖动来探索不同的睡眠阶段。
- 🕐 **时间显示**: 显示详细的时间范围和持续时间。
- 🎯 **Apple Health 风格**: 模仿 Apple Health 应用的优雅设计。
- ✨ **支持冥想**: 使用单独的图表显示冥想数据。
- 🎀 **可自定义页脚**: 页脚可以自定义。
- 🏆 **文档齐全**：完整的使用文档和示例。

## 安装

将此添加到包的 `pubspec.yaml` 文件中：

```yaml
dependencies:
  sleep_stage_chart: ^1.1.0
```

然后运行：

```bash
flutter pub get
```

## 用法

支持睡眠阶段图和冥想图。

### 睡眠阶段图表示例

```dart
import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

class SleepChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 创建示例睡眠数据
    final sleepData = [
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: DateTime(2025, 1, 1, 22, 30),
        endTime: DateTime(2025, 1, 1, 23, 30),
        info: ['浅睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: DateTime(2025, 1, 1, 23, 30),
        endTime: DateTime(2025, 1, 2, 1, 0),
        info: ['深睡'],
      ),
      // 添加更多睡眠阶段...
    ];

    return Container(
      height: 300,
      alignment: Alignment.center,
      child: SleepStageChart(
        details: sleepData,
        startTime: DateTime(2024, 1, 1, 22, 30),
        endTime: DateTime(2024, 1, 2, 6, 30),
        heightUnitRatio: 1 / 8,
        backgroundColor: Colors.white,
        onIndicatorMoved: (stage) {
          print('Current stage: ${stage.model}');
        },
        xAxisBottomHeight: 32,
        bottomChild: [
          Text('开始'),
          Text('结束'),
        ],
      ),
    );
  }
}
```

### 冥想图表示例

```dart
import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

Container(
  alignment: Alignment.center,
  height: 300,
  child: SleepStageChart(
    heightUnitRatio: 1 / 8,
    xAxisBottomHeight: 32,
    backgroundColor: Colors.transparent,
    borderRadius: 8,
    horizontalLineCount: 4,
    showVerticalLine: true,
    showHorizontalLine: false,
    details: [
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: dayStart,
        endTime: dayStart.add(const Duration(minutes: 45)),
        info: ['冥想'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: dayStart.add(const Duration(hours: 2)),
        endTime: dayStart.add(const Duration(hours: 3, minutes: 15)),
        info: ['冥想'],
      ),
      // 更多......
    ],
    startTime: meditationStartTime,
    endTime: meditationEndTime,
    stageColors: const {
      SleepStageEnum.light: Color(0xFF43CAC4),
      SleepStageEnum.deep: Color(0xFF43CAC4),
      SleepStageEnum.rem: Color(0xFF43CAC4),
      SleepStageEnum.awake: Color(0xFF43CAC4),
    },
    onIndicatorMoved: (item) {
      print('${item.model}');
    },
    allDayModel: true,
    minuteInterval: 360,
    bottomChild: ['00:00', '06:00', '12:00', '18:00', '00:00']
        .map((v) => Text(v))
        .toList(),
  ),
),
```

## API 参考

### SleepStageChart

用于显示睡眠阶段图表的主小部件。

#### 属性

| 属性名 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `details` | List<SleepStageDetails> | - | 睡眠详细信息数据（必需） |
| `startTime` | DateTime | - | 开始时间（必需） |
| `endTime` | DateTime | - | 结束时间（必需） |
| `heightUnitRatio` | double | - | 高度比率单位 |
| `xAxisBottomHeight` | double | 20 | X 轴底部标题高度 |
| `backgroundColor` | Color | - | 背景颜色（必需） |
| `borderRadius` | double | 8.0 | 色块边框半径 |
| `connectorLineWidth` | double | 2.0 | 连接器线宽 |
| `horizontalLineStyle` | SleepStageChartLineStyle | - | 水平线样式 |
| `verticalLineStyle` | SleepStageChartLineStyle | - | 垂直线样式 |
| `horizontalLineCount` | int | 8 | 图表被水平线分割成的段数 |
| `dividerPaintStyle` | SleepStageChartPaintStyle | - | |
| `stageColors` | Map<SleepStageEnum, Color>? | null | 睡眠阶段颜色映射 |
| `dateFormatter` | String Function(DateTime)? | null | 日期格式化函数 |
| `showVerticalLine` | bool | true | 是否显示垂直线 |
| `showHorizontalLine` | bool | true | 是否显示水平线 |
| `hasIndicator` | bool | true | 是否显示指示器 |
| `onIndicatorMoved` | void Function(SleepStageDetails)? | null | 指示器移动到不同色块时的回调 |
| `allDayModel` | bool | false | 全天模式 |
| `minuteInterval` | int | 360 | 全天模式的分钟间隔（默认为 360 分钟） |
| `bottomChild` | List<Widget> | const [] | 底部子小部件的集合 |

### SleepStageDetails

表示单个睡眠阶段周期。

#### 属性

| 属性 | 类型 | 描述 |
| --- | --- | --- |
| `model` | `SleepStageEnum` | 睡眠阶段类型 |
| `startTime` | `DateTime` | 阶段开始时间 |
| `endTime` | `DateTime` | 阶段结束时间 |
| `duration` | `int` | 持续时间（分钟） |

### SleepStageEnum

表示不同睡眠阶段的枚举：

- `SleepStageEnum.light` - 浅睡
- `SleepStageEnum.deep` - 深睡
- `SleepStageEnum.rem` - 快速眼动睡眠
- `SleepStageEnum.awake` - 清醒
- `SleepStageEnum.notWorn` - 未佩戴设备
- `SleepStageEnum.unknown` - 未知状态

## 定制

### 颜色

您可以为不同的睡眠阶段自定义颜色：

```dart
final customColors = {
  SleepStageEnum.light: Colors.blue.shade300,
  SleepStageEnum.deep: Colors.blue.shade700,
  SleepStageEnum.rem: Colors.teal.shade300,
  SleepStageEnum.awake: Colors.orange.shade300,
};

SleepStageChart(
  // ... other properties
  stageColors: customColors,
)
```

### 网格线

自定义网格线的外观：

```dart
SleepStageChart(
  // ... other properties
  horizontalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  verticalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  showHorizontalLine: true,
  showVerticalLine: true,
)
```

### 文本格式

自定义日期和时间格式：

```dart
SleepStageChart(
  // ... other properties
  dateFormatter: (DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  },
  bottomInfoTextStyle: TextStyle(
    color: Colors.grey,
    fontSize: 12,
  ),
)
```

## 示例应用

查看 [example](example/) 目录以获取一个完整的、可工作的示例，该示例演示了此插件的所有功能。

要运行示例：

```bash
cd example
flutter pub get
flutter run
```

## 贡献

欢迎贡献！请随时提交拉取请求。

## 许可证

该项目根据 MIT 许可证授权 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## 支持

如果您喜欢这个插件，请在 GitHub 上给它一个 ⭐，并考虑支持开发！

对于问题和功能请求，请使用 [GitHub Issues](https://github.com/your-username/sleep_stage_chart/issues) 页面。