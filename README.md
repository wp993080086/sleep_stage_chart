# Sleep Stage Chart

[中文文档](https://github.com/wp993080086/sleep_stage_chart/blob/master/README_zh.md)

A Flutter plugin for displaying visual charts of sleep stages and sleep quality data, and also supports meditation charts. Compatible with Android, iOS and Windows platforms.

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep.png)
![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/meditation.png)

## Features

- 📊 **Beautiful Sleep Charts**: Display sleep stages with clear color blocks and gradients.
- 😜 **Nap Support**: Support for naps and short sleeps.
- 🎨 **Customizable**: Full control over colors, styles, and layout.
- 📱 **Cross Platform**: Works on both Android and iOS and Windows.
- 🤏 **Interactive**: Touch and drag to explore different sleep stages.
- 🕐 **Time Display**: Shows detailed time ranges and durations.
- 🎯 **Apple Health Style**: Mimics the elegant design of Apple Health app.
- ✨ **Meditation Support**: Display meditation data with a separate chart.
- 🎀 **Customizable Footer**: The footer can be customized.
- 🏆 **The document is complete.**：Complete usage documentation and examples.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sleep_stage_chart: ^1.2.0
```

Then run:

```bash
flutter pub get
```

## Usage

Support sleep stage chart and meditation chart.

### Sleep Stage Chart Example

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep-tooltip.png)

```dart
import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

class SleepChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create sample sleep data
    final sleepData = [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: DateTime(2025, 1, 1, 22, 30),
        end: DateTime(2025, 1, 1, 22, 45),
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: DateTime(2025, 1, 1, 22, 45),
        end: DateTime(2025, 1, 1, 23, 45),
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.deep,
        start: DateTime(2025, 1, 1, 23, 45),
        end: DateTime(2025, 1, 2, 1, 15),
      ),
      // Add more sleep stages...
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
          print('${stage.type.title} ${stage.duration.inMinutes}min');
        },
      ),
    );
  }
}
```

### Meditation Chart Example

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
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.inBed,
        start: dayStart.add(const Duration(hours: 2)),
        end: dayStart.add(const Duration(hours: 3, minutes: 15)),
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
        stageNameFormatter: (_) => 'Meditation',
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

## API Reference

### SleepStageChart

The main widget for displaying sleep stage charts.

#### Properties

| Property Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| `data` | `List<SleepStageChartSegment>` | - | Sleep stage data list (required) |
| `dateFrom` | `DateTime` | - | Chart start time (required) |
| `dateTo` | `DateTime` | - | Chart end time (required) |
| `stageHeightRatio` | `double` | - | Height ratio of each stage block, range [0, 0.25] |
| `stageVerticalGapRatio` | `double` | - | Vertical gap ratio between stages, range [0, 1.0] |
| `backgroundColor` | `Color` | - | Background color (required) |
| `borderRadius` | `double` | 4.0 | Border radius of stage blocks |
| `connectorLineWidth` | `double` | 1.0 | Width of connector lines between adjacent blocks |
| `horizontalLineStyle` | `SleepStageChartLineStyle` | `defaultLineStyle` | Horizontal grid line style |
| `verticalLineStyle` | `SleepStageChartLineStyle` | `defaultLineStyle` | Vertical grid line style |
| `horizontalNodes` | `List<double>` | `[]` | Horizontal line positions, range [0.0, 1.0] |
| `verticalNodes` | `List<double>` | `[]` | Vertical line positions, range [0.0, 1.0] |
| `verticalLineVisible` | `bool` | true | Whether to show vertical grid lines |
| `horizontalLineVisible` | `bool` | true | Whether to show horizontal grid lines |
| `hasTooltip` | `bool` | true | Whether to show tooltip |
| `hasTooltipIndicator` | `bool` | true | Whether to show tooltip indicator (vertical line) |
| `tooltipOffset` | `double` | 0.0 | Tooltip vertical offset |
| `tooltipPadding` | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(horizontal: 12, vertical: 6)` | Tooltip padding |
| `tooltipBackgroundColor` | `Color?` | null | Tooltip background color (defaults to stage color) |
| `tooltipBorderRadius` | `double` | 12.0 | Tooltip border radius |
| `tooltipPrimaryTextStyle` | `TextStyle?` | null | Primary text style (duration) |
| `tooltipSecondaryTextStyle` | `TextStyle?` | null | Secondary text style (stage name and time) |
| `allDayMode` | `bool` | false | All-day mode (single centered block) |
| `allDayColor` | `Color?` | `Color(0xFF43CAC4)` | Color for all-day mode |
| `stageColors` | `Map<SleepStageTypeEnum, Color>?` | null | Custom stage colors |
| `stageOrder` | `List<SleepStageTypeEnum>?` | `[awake, core, rem, deep]` | Stage display order |
| `dateFormatter` | `String Function(DateTime)?` | null | Date formatter function |
| `stageNameFormatter` | `String Function(SleepStageTypeEnum)?` | null | Stage name formatter function |
| `footerHeight` | `double` | 40.0 | Footer area height |
| `footerChildren` | `List<Widget>` | `[]` | Footer child widgets |
| `onStageChanged` | `void Function(SleepStageChartSegment)?` | null | Callback when indicator points to different stage |
| `onIndicatorMove` | `void Function(SleepStageChartSegment)?` | null | Callback when indicator moves |
| `onIndicatorLongPress` | `void Function(SleepStageChartSegment)?` | null | Callback when indicator is long pressed |
| `onStageTap` | `void Function(SleepStageChartSegment)?` | null | Callback when stage block is tapped |

### SleepStageChartSegment

Represents a single sleep stage period.

#### Properties

| Property | Type | Description |
| --- | --- | --- |
| `type` | `SleepStageTypeEnum` | Sleep stage type |
| `start` | `DateTime` | Stage start time |
| `end` | `DateTime` | Stage end time |
| `duration` | `Duration` | Duration (getter, calculated from start and end) |

### SleepStageTypeEnum

Enum representing different sleep stages:

- `SleepStageTypeEnum.awake` - Awake
- `SleepStageTypeEnum.core` - Core sleep (light sleep)
- `SleepStageTypeEnum.deep` - Deep sleep
- `SleepStageTypeEnum.rem` - REM sleep
- `SleepStageTypeEnum.unknown` - Unknown state (for nap gaps)
- `SleepStageTypeEnum.inBed` - In bed (for meditation)

### SleepStageChartLineStyle

Defines the style of grid lines.

#### Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `double` | 1.0 | Line width |
| `color` | `Color` | `Color(0xFFE0E0E0)` | Line color |
| `dashLength` | `double` | 0.0 | Dash length (0 for solid line) |
| `space` | `double` | 0.0 | Space between dashes |

## Customization

### Colors

You can customize the colors for different sleep stages:

```dart
final customColors = {
  SleepStageTypeEnum.core: Colors.blue.shade300,
  SleepStageTypeEnum.deep: Colors.blue.shade700,
  SleepStageTypeEnum.rem: Colors.teal.shade300,
  SleepStageTypeEnum.awake: Colors.orange.shade300,
};

SleepStageChart(
  // ... other properties
  stageColors: customColors,
)
```

### Grid Lines

Customize the appearance of grid lines:

```dart
SleepStageChart(
  // ... other properties
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

### Text Formatting

Customize date and time formatting:

```dart
SleepStageChart(
  // ... other properties
  dateFormatter: (DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  },
  stageNameFormatter: (SleepStageTypeEnum type) {
    return type.title; // or custom mapping
  },
)
```

## Example App

Check out the [example](example/) directory for a complete working example that demonstrates all the features of this plugin.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you like this plugin, please give it a ⭐ on GitHub and consider supporting the development!

For issues and feature requests, please use the [GitHub Issues](https://github.com/your-username/sleep_stage_chart/issues) page.
