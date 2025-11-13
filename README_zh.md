# 睡眠阶段图表

一个 Flutter 插件，用于可视化展示睡眠阶段和睡眠质量数据，同时支持冥想图表展示。兼容 Android、iOS 和 Windows 平台。

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep.png)
![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/meditation.png)

## 功能特点

- 📊 **美观睡眠图表**：以流畅过渡和渐变效果展示睡眠阶段。
- 🎨 **高度可定制**：完全掌控颜色、样式和布局。
- 📱 **跨平台兼容**：支持 Android、iOS 和 Windows 系统。
- 🤏 **交互体验**：触摸并拖动可查看不同睡眠阶段详情。
- 🕐 **时间展示**：显示详细的时间范围和持续时长。
- 🎯 **苹果健康风格**：复刻苹果健康应用的优雅设计。
- ✨ **冥想数据支持**：通过独立图表展示冥想数据。
- 🎀 **自定义底部区域**：可自由定制底部展示内容。
- 🏆 **文档完善**：提供完整的使用文档和示例代码。

## 安装步骤

在项目的 `pubspec.yaml` 文件中添加以下依赖：

```yaml
dependencies:
  sleep_stage_chart: ^1.1.0
```

然后执行以下命令：

```bash
flutter pub get
```

## 使用方法

支持睡眠阶段图表和冥想图表两种展示模式。

### 睡眠阶段图表示例

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep-tooltip.png)

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
      // 可添加更多睡眠阶段数据...
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
          print('当前阶段: ${stage.model}');
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

![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/meditation-tooltip.png)

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
        startTime: 一天起始时间,
        endTime: 一天起始时间.add(const Duration(minutes: 45)),
        info: ['冥想'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: 一天起始时间.add(const Duration(hours: 2)),
        endTime: 一天起始时间.add(const Duration(hours: 3, minutes: 15)),
        info: ['冥想'],
      ),
      // 可添加更多数据...
    ],
    startTime: 冥想开始时间,
    endTime: 冥想结束时间,
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
);
```

## API 参考

### SleepStageChart

展示睡眠阶段图表的核心组件。

#### 属性说明

| 属性名 | 类型 | 默认值 | 说明 |
| ---- | ---- | ---- | ---- |
| `details` | List&lt;SleepStageDetails&gt; | - | 睡眠详情数据（必填） |
| `startTime` | DateTime | - | 开始时间（必填） |
| `endTime` | DateTime | - | 结束时间（必填） |
| `heightUnitRatio` | double | - | 高度比例单位 |
| `xAxisBottomHeight` | double | 20 | X轴底部标题高度 |
| `backgroundColor` | Color | - | 背景颜色（必填） |
| `borderRadius` | double | 8.0 | 色块圆角 |
| `connectorLineWidth` | double | 2.0 | 连接线宽度 |
| `horizontalLineStyle` | SleepStageChartLineStyle | - | 水平线样式 |
| `verticalLineStyle` | SleepStageChartLineStyle | - | 垂直线样式 |
| `horizontalLineCount` | int | 8 | 图表被水平线分割的段数 |
| `dividerPaintStyle` | SleepStageChartPaintStyle | - | 分割线绘制样式 |
| `stageColors` | Map&lt;SleepStageEnum, Color&gt;? | null | 睡眠阶段颜色映射 |
| `dateFormatter` | String Function(DateTime)? | null | 日期格式化函数 |
| `showVerticalLine` | bool | true | 是否显示垂直线 |
| `showHorizontalLine` | bool | true | 是否显示水平线 |
| `hasIndicator` | bool | true | 是否显示指示器 |
| `onIndicatorMoved` | void Function(SleepStageDetails)? | null | 指示器移动到不同色块时的回调函数 |
| `allDayModel` | bool | false | 全天模式 |
| `minuteInterval` | int | 360 | 全天模式下的时间间隔（默认360分钟） |
| `bottomChild` | List&lt;Widget&gt; | const [] | 底部子组件集合 |

### SleepStageDetails

表示单个睡眠阶段的时间段数据。

#### 属性说明

| 属性名 | 类型 | 说明 |
| ---- | ---- | ---- |
| `model` | `SleepStageEnum` | 睡眠阶段类型 |
| `startTime` | `DateTime` | 阶段开始时间 |
| `endTime` | `DateTime` | 阶段结束时间 |
| `duration` | `int` | 持续时长（单位：分钟） |

### SleepStageEnum

表示不同睡眠阶段的枚举类：

- `SleepStageEnum.light` - 浅睡
- `SleepStageEnum.deep` - 深睡
- `SleepStageEnum.rem` - 快速眼动睡眠（REM）
- `SleepStageEnum.awake` - 清醒
- `SleepStageEnum.notWorn` - 未佩戴设备
- `SleepStageEnum.unknown` - 未知状态

## 定制化配置

### 颜色定制

可自定义不同睡眠阶段的颜色：

```dart
final customColors = {
  SleepStageEnum.light: Colors.blue.shade300,
  SleepStageEnum.deep: Colors.blue.shade700,
  SleepStageEnum.rem: Colors.teal.shade300,
  SleepStageEnum.awake: Colors.orange.shade300,
};

SleepStageChart(
  // ... 其他属性
  stageColors: customColors,
)
```

### 网格线定制

定制网格线的显示效果：

```dart
SleepStageChart(
  // ... 其他属性
  horizontalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  verticalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  showHorizontalLine: true,
  showVerticalLine: true,
)
```

### 文本格式化

自定义日期和时间的展示格式：

```dart
SleepStageChart(
  // ... 其他属性
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

查看 [example/](example/) 目录，获取完整的示例项目，展示插件的所有功能。

运行示例步骤：

```bash
cd example
flutter pub get
flutter run
```

## 贡献代码

欢迎提交代码贡献！请直接提交 Pull Request 即可。

## 许可证

本项目基于 MIT 许可证开源 - 详见 [LICENSE](LICENSE) 文件获取详细信息。

## 支持与反馈

如果喜欢这个插件，欢迎在 GitHub 上给它点个 ⭐，也可以支持项目开发！

如有问题或功能需求，请通过 [GitHub Issues](https://github.com/your-username/sleep_stage_chart/issues) 提交。

要不要我帮你整理一份**插件核心功能速查表**，方便快速查阅关键配置和使用场景？