# Sleep Stage Chart

[中文文档](https://github.com/wp993080086/sleep_stage_chart/blob/master/README_zh.md)

A Flutter plugin for displaying visual charts of sleep stages and sleep quality data, and also supports meditation charts. Compatible with Android, iOS and Windows platforms.

![Sleep Stage Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/sleep.png)
![Meditation Chart Example](https://raw.githubusercontent.com/wp993080086/sleep_stage_chart/refs/heads/master/doc/images/meditation.png)

## Features

- 📊 **Beautiful Sleep Charts**: Display sleep stages with smooth transitions and gradients.
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
  sleep_stage_chart: ^1.1.0
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
      // Add more sleep stages...
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
          Text('Start'),
          Text('End'),
        ],
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
      // More......
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

## API Reference

### SleepStageChart

The main widget for displaying sleep stage charts.

#### Properties

| Property Name       | Type                              | Default Value | Description                                                      |
| ------------------- | --------------------------------- | ------------- | ---------------------------------------------------------------- |
| `details`             | List&lt;SleepStageDetails&gt;     | -             | Sleep detail data (required)                                     |
| `startTime`           | DateTime                          | -             | Start time (required)                                            |
| `endTime`             | DateTime                          | -             | End time (required)                                              |
| `heightUnitRatio`     | double                            | -             | Height ratio unit                                                |
| `xAxisBottomHeight`   | double                            | 20            | X-axis bottom title height                                       |
| `backgroundColor`     | Color                             | -             | Background color (required)                                      |
| `borderRadius`        | double                            | 8.0           | Color block border radius                                        |
| `connectorLineWidth`  | double                            | 2.0           | Connector line width                                             |
| `horizontalLineStyle` | SleepStageChartLineStyle          | -             | Horizontal line style                                            |
| `verticalLineStyle`   | SleepStageChartLineStyle          | -             | Vertical line style                                              |
| `horizontalLineCount` | int                               | 8             | Number of segments the chart is divided into by horizontal lines |
| `dividerPaintStyle`   | SleepStageChartPaintStyle         | -             |
| `stageColors`         | Map&lt;SleepStageEnum, Color&gt;? | null          | Sleep stage color mapping                                        |
| `dateFormatter`       | String Function(DateTime)?        | null          | Date formatting function                                         |
| `showVerticalLine`    | bool                              | true          | Whether to show vertical lines                                   |
| `showHorizontalLine`  | bool                              | true          | Whether to show horizontal lines                                 |
| `hasIndicator`        | bool                              | true          | Whether to show indicator                                        |
| `onIndicatorMoved`    | void Function(SleepStageDetails)? | null          | Callback when indicator moves to different color blocks          |
| `allDayModel`         | bool                              | false         | All-day mode                                                     |
| `minuteInterval`      | int                               | 360           | Minute interval for all-day mode (default 360 minutes)           |
| `bottomChild`         | List&lt;Widget&gt;                | const []      | Collection of bottom child widgets                               |

### SleepStageDetails

Represents a single sleep stage period.

#### Properties

| Property    | Type             | Description         |
| ----------- | ---------------- | ------------------- |
| `model`     | `SleepStageEnum` | Sleep stage type    |
| `startTime` | `DateTime`       | Stage start time    |
| `endTime`   | `DateTime`       | Stage end time      |
| `duration`  | `int`            | Duration in minutes |

### SleepStageEnum

Enum representing different sleep stages:

- `SleepStageEnum.light` - Light sleep
- `SleepStageEnum.deep` - Deep sleep
- `SleepStageEnum.rem` - REM sleep
- `SleepStageEnum.awake` - Awake
- `SleepStageEnum.notWorn` - Device not worn
- `SleepStageEnum.unknown` - Unknown state

## Customization

### Colors

You can customize the colors for different sleep stages:

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

### Grid Lines

Customize the appearance of grid lines:

```dart
SleepStageChart(
  // ... other properties
  horizontalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  verticalLineStyle: SleepStageChartLineStyle(width: 3.0, space: 5.0),
  showHorizontalLine: true,
  showVerticalLine: true,
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
  bottomInfoTextStyle: TextStyle(
    color: Colors.grey,
    fontSize: 12,
  ),
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
