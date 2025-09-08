# Sleep Stage Chart

A Flutter plugin for displaying visualized charts of sleep phases and sleep quality data, supporting both Android and iOS platforms. This plugin offers an elegant and interactive way to present sleep data—including deep sleep, light sleep, REM sleep, and awake periods—imitates the style of the Apple Health App, and also supports customization.

## Features

- 📊 **Beautiful Sleep Charts**: Display sleep stages with smooth transitions and gradients
- 🎨 **Customizable**: Full control over colors, styles, and layout
- 📱 **Cross Platform**: Works on both Android and iOS
- 🤏 **Interactive**: Touch and drag to explore different sleep stages

- 🕐 **Time Display**: Shows detailed time ranges and durations
- 🎯 **Apple Health Style**: Mimics the elegant design of Apple Health app

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sleep_stage_chart: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

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
        startTime: DateTime(2024, 1, 1, 22, 30),
        endTime: DateTime(2024, 1, 1, 23, 30),
        duration: 60,
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: DateTime(2024, 1, 1, 23, 30),
        endTime: DateTime(2024, 1, 2, 1, 0),
        duration: 90,
      ),
      // Add more sleep stages...
    ];

    return Container(
      height: 300,
      child: SleepStageChart(
        details: sleepData,
        startTime: DateTime(2024, 1, 1, 22, 30),
        endTime: DateTime(2024, 1, 2, 6, 30),
        heightUnit: 0.6,
        xAxisTitleOffset: 40.0,
        xAxisTitleHeight: 30.0,
        bgColor: Colors.white,
        onIndicatorMoved: (stage) {
          print('Current stage: ${stage.model}');
        },
      ),
    );
  }
}
```

### Custom Paint Example

For more control, you can use the `SleepStageChartPainter` directly:

```dart
CustomPaint(
  painter: SleepStageChartPainter(
    heightUnit: 0.6,
    xAxisTitleOffset: 40.0,
    bgColor: Colors.white,
    details: sleepData,
    startTime: startTime,
    endTime: endTime,
    xAxisTitleHeight: 30.0,
    borderRadius: 8.0,
    connectorLineWidth: 2.0,
    indicatorPosition: 0.5,
    horizontalLineStyle: SleepStageChartLineStyle(width: 5.0, space: 3.0),
    verticalLineStyle: SleepStageChartLineStyle(width: 5.0, space: 3.0),
    horizontalLineCount: 8,
    dividerPaintStyle: SleepStageChartPaintStyle(
      color: Color(0xFFEEEEEE),
      strokeWidth: 1.0,
      style: PaintingStyle.stroke,
      strokeCap: StrokeCap.round,
    ),
    stageColorMap: {
      SleepStageEnum.light: Color(0xFF54B0FF),
      SleepStageEnum.deep: Color(0xFF4D58E7),
      SleepStageEnum.rem: Color(0xFF82DDDD),
      SleepStageEnum.awake: Color(0xFFFFA877),
    },
  ),
)
```

## API Reference

### SleepStageChart

The main widget for displaying sleep stage charts.

#### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `details` | `List<SleepStageDetails>` | Sleep stage data | Required |
| `startTime` | `DateTime` | Chart start time | Required |
| `endTime` | `DateTime` | Chart end time | Required |
| `heightUnit` | `double` | Height ratio (0-1) | Required |
| `xAxisTitleOffset` | `double` | Bottom title offset | Required |
| `xAxisTitleHeight` | `double` | Bottom title height | Required |
| `bgColor` | `Color` | Background color | Required |
| `borderRadius` | `double` | Corner radius | `8.0` |
| `connectorLineWidth` | `double` | Connection line width | `2.0` |
| `hasIndicator` | `bool` | Show indicator | `true` |

| `onIndicatorMoved` | `Function(SleepStageDetails)?` | Indicator callback | `null` |

### SleepStageDetails

Represents a single sleep stage period.

#### Properties

| Property | Type | Description |
|----------|------|--------------|
| `model` | `SleepStageEnum` | Sleep stage type |
| `startTime` | `DateTime` | Stage start time |
| `endTime` | `DateTime` | Stage end time |
| `duration` | `int` | Duration in minutes |

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