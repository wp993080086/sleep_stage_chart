# 睡眠阶段图表

一个 Flutter 插件，用于可视化展示睡眠阶段和睡眠质量数据，同时支持冥想图表展示。兼容 Android、iOS 和 Windows 平台。

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep.png)
![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/meditation.png)

## 功能特点

- 📊 **美观睡眠图表**：以清晰的色块和渐变效果展示睡眠阶段。
- 😜 **支持午睡**：支持午睡和零星小睡。
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
  sleep_stage_chart: ^1.2.0
```

然后执行以下命令：

```bash
flutter pub get
```

## 使用方法

支持睡眠阶段图表和冥想图表两种展示模式。

### 睡眠阶段图表示例

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep-tooltip.png)

![Sleep Nap Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep-nap-tooltip.png)

```dart
import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

class SleepChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 创建示例睡眠数据
    final sleepData = [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: DateTime(2025, 1, 1, 22, 30),
        end: DateTime(2025, 1, 1, 22, 45),
        titles: const ['清醒'],
        subtitle: '22:30-22:45',
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: DateTime(2025, 1, 1, 22, 45),
        end: DateTime(2025, 1, 1, 23, 45),
        titles: const ['核心'],
        subtitle: '22:45-23:45',
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.deep,
        start: DateTime(2025, 1, 1, 23, 45),
        end: DateTime(2025, 1, 2, 1, 15),
        titles: const ['深度'],
        subtitle: '23:45-01:15',
      ),
      // 可添加更多睡眠阶段数据...
    ];

    final sleepStart = sleepData.first.start;
    final sleepEnd = sleepData.last.end;

    return Container(
      height: 300,
      alignment: Alignment.center,
      child: SleepStageChart(
        data: sleepData,
        dateFrom: sleepStart,
        dateTo: sleepEnd,
        stageHeightRatio: 0.15,
        stageVerticalGapRatio: 0.1,
        backgroundColor: Colors.white,
        verticalLineVisible: false,
        horizontalNodes: const [0.0, 0.25, 0.5, 0.75, 1.0],
        tooltipOffset: 20,
        footerHeight: 28,
        connectorLineWidth: 1.0,
        footerChildren: [
          Text('22:30'),
          Text('07:10'),
        ],
        onStageChanged: (stage) {
          print('${stage.type.title} ${stage.duration.inMinutes}分钟');
        },
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

class MeditationChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day, 6, 0);

    final meditationData = [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.inBed,
        start: dayStart,
        end: dayStart.add(const Duration(minutes: 45)),
        titles: const ['冥想'],
        subtitle: '06:00-06:45',
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.inBed,
        start: dayStart.add(const Duration(hours: 2)),
        end: dayStart.add(const Duration(hours: 3, minutes: 15)),
        titles: const ['冥想'],
        subtitle: '08:00-09:15',
      ),
    ];

    return Container(
      alignment: Alignment.center,
      height: 300,
      child: SleepStageChart(
        data: meditationData,
        dateFrom: DateTime(now.year, now.month, now.day),
        dateTo: DateTime(now.year, now.month, now.day, 23, 59, 59),
        stageHeightRatio: 0.25,
        stageVerticalGapRatio: 0,
        backgroundColor: Colors.transparent,
        borderRadius: 8,
        horizontalLineVisible: false,
        verticalNodes: const [0.0, 0.25, 0.5, 0.75, 1.0],
        allDayMode: true,
        allDayColor: const Color(0xFF00B894),
        tooltipOffset: 15,
        footerHeight: 28,
        footerChildren: const [
          Text('00:00'),
          Text('06:00'),
          Text('12:00'),
          Text('18:00'),
          Text('24:00'),
        ],
      ),
    );
  }
}
```

## API 参考

### SleepStageChart

展示睡眠阶段图表的核心组件。

#### 属性说明

| 属性名                         | 类型                                     | 默认值                                              | 说明                                   |
| ------------------------------ | ---------------------------------------- | --------------------------------------------------- | -------------------------------------- |
| `data`                         | `List<SleepStageChartSegment>`           | -                                                   | 睡眠阶段数据列表（必填）               |
| `dateFrom`                     | `DateTime`                               | -                                                   | 图表开始时间（必填）                   |
| `dateTo`                       | `DateTime`                               | -                                                   | 图表结束时间（必填）                   |
| `stageHeightRatio`             | `double`                                 | -                                                   | 色块高度比例，范围 [0, 0.25]           |
| `stageVerticalGapRatio`        | `double`                                 | -                                                   | 色块间距比例，范围 [0, 1.0]            |
| `backgroundColor`              | `Color`                                  | -                                                   | 背景颜色（必填）                       |
| `borderRadius`                 | `double`                                 | 4.0                                                 | 色块圆角半径                           |
| `connectorLineWidth`           | `double`                                 | 1.0                                                 | 连接线宽度                             |
| `horizontalLineStyle`          | `SleepStageChartLineStyle`               | `defaultLineStyle`                                  | 水平网格线样式                         |
| `verticalLineStyle`            | `SleepStageChartLineStyle`               | `defaultLineStyle`                                  | 垂直网格线样式                         |
| `horizontalNodes`              | `List<double>`                           | `[]`                                                | 水平线位置，范围 [0.0, 1.0]            |
| `verticalNodes`                | `List<double>`                           | `[]`                                                | 垂直线位置，范围 [0.0, 1.0]            |
| `verticalLineVisible`          | `bool`                                   | true                                                | 是否显示垂直网格线                     |
| `horizontalLineVisible`        | `bool`                                   | true                                                | 是否显示水平网格线                     |
| `hasTooltip`                   | `bool`                                   | true                                                | 是否显示 Tooltip                       |
| `hasTooltipIndicator`          | `bool`                                   | true                                                | 是否显示 Tooltip 指示器（垂直线）      |
| `tooltipOffset`                | `double`                                 | 0.0                                                 | Tooltip 垂直偏移                       |
| `tooltipPadding`               | `EdgeInsetsGeometry?`                    | `EdgeInsets.symmetric(horizontal: 12, vertical: 6)` | Tooltip 内边距                         |
| `tooltipBackgroundColor`       | `Color?`                                 | null                                                | Tooltip 背景颜色（默认使用阶段颜色）   |
| `tooltipBorderRadius`          | `double`                                 | 12.0                                                | Tooltip 圆角半径                       |
| `tooltipPrimaryTextStyleBig`   | `TextStyle?`                             | null                                                | 主文字大字号样式（持续时长大字号部分） |
| `tooltipPrimaryTextStyleSmall` | `TextStyle?`                             | null                                                | 主文字小字号样式（持续时长小字号部分） |
| `tooltipSecondaryTextStyle`    | `TextStyle?`                             | null                                                | 次文字样式（阶段名称和时间范围）       |
| `hasTitleHump`                 | `bool`                                   | true                                                | 标题是否使用驼峰样式（大小文字交替）   |
| `allDayMode`                   | `bool`                                   | false                                               | 全天模式（单个居中色块）               |
| `allDayColor`                  | `Color?`                                 | `Color(0xFF43CAC4)`                                 | 全天模式下的色块颜色                   |
| `stageColors`                  | `Map<SleepStageTypeEnum, Color>?`        | null                                                | 自定义阶段颜色                         |
| `stageOrder`                   | `List<SleepStageTypeEnum>?`              | `[awake, core, rem, deep]`                          | 阶段显示顺序                           |
| `footerHeight`                 | `double`                                 | 40.0                                                | 底部区域高度                           |
| `footerChildren`               | `List<Widget>`                           | `[]`                                                | 底部子组件列表                         |
| `onStageChanged`               | `void Function(SleepStageChartSegment)?` | null                                                | 指示器指向不同阶段时的回调             |
| `onIndicatorMove`              | `void Function(SleepStageChartSegment)?` | null                                                | 指示器移动时的回调                     |
| `onIndicatorLongPress`         | `void Function(SleepStageChartSegment)?` | null                                                | 长按指示器时的回调                     |
| `onStageTap`                   | `void Function(SleepStageChartSegment)?` | null                                                | 点击阶段色块时的回调                   |

### SleepStageChartSegment

表示单个睡眠阶段的时间段数据。

#### 属性说明

| 属性名     | 类型                 | 说明                                     |
| ---------- | -------------------- | ---------------------------------------- |
| `type`     | `SleepStageTypeEnum` | 睡眠阶段类型                             |
| `start`    | `DateTime`           | 阶段开始时间                             |
| `end`      | `DateTime`           | 阶段结束时间                             |
| `titles`   | `List<String>`       | 主标题列表（用于 Tooltip 显示）          |
| `subtitle` | `String?`            | 副标题（用于 Tooltip 显示）              |
| `duration` | `Duration`           | 持续时长（getter，由 start 和 end 计算） |

### SleepStageTypeEnum

表示不同睡眠阶段的枚举类：

- `SleepStageTypeEnum.awake` - 清醒
- `SleepStageTypeEnum.core` - 核心睡眠（浅睡）
- `SleepStageTypeEnum.deep` - 深睡
- `SleepStageTypeEnum.rem` - 快速眼动睡眠
- `SleepStageTypeEnum.unknown` - 未知状态（用于午睡间隙）
- `SleepStageTypeEnum.inBed` - 在床上（用于冥想）

### SleepStageChartLineStyle

定义网格线的样式。

#### 属性说明

| 属性名       | 类型     | 默认值              | 说明                   |
| ------------ | -------- | ------------------- | ---------------------- |
| `width`      | `double` | 1.0                 | 线宽                   |
| `color`      | `Color`  | `Color(0xFFE0E0E0)` | 线条颜色               |
| `dashLength` | `double` | 0.0                 | 虚线长度（0 表示实线） |
| `space`      | `double` | 0.0                 | 虚线间隔               |

## 定制化配置

### 颜色定制

可自定义不同睡眠阶段的颜色：

```dart
final customColors = {
  SleepStageTypeEnum.core: Colors.blue.shade300,
  SleepStageTypeEnum.deep: Colors.blue.shade700,
  SleepStageTypeEnum.rem: Colors.teal.shade300,
  SleepStageTypeEnum.awake: Colors.orange.shade300,
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
  horizontalLineStyle: SleepStageChartLineStyle(
    width: 1,
    space: 3,
    dashLength: 3,
    color: Colors.grey.shade300,
  ),
  verticalLineStyle: SleepStageChartLineStyle(
    width: 1,
    space: 3,
    dashLength: 3,
    color: Colors.grey.shade300,
  ),
  horizontalLineVisible: true,
  verticalLineVisible: true,
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

![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/example.png)

## 贡献代码

欢迎提交代码贡献！请直接提交 Pull Request 即可。

## 许可证

本项目基于 MIT 许可证开源 - 详见 [LICENSE](LICENSE) 文件获取详细信息。

## 支持与反馈

如果喜欢这个插件，欢迎在 GitHub 上给它点个 ⭐，也可以支持项目开发！

如有问题或功能需求，请通过 [GitHub Issues](https://github.com/your-username/sleep_stage_chart/issues) 提交。
