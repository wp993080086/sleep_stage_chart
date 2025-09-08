import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

void main() {
  group('SleepStageDetails', () {
    test('should create SleepStageDetails with correct properties', () {
      final startTime = DateTime(2024, 1, 1, 22, 30);
      final endTime = DateTime(2024, 1, 1, 23, 30);
      const duration = 60;

      final sleepStage = SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
      );

      expect(sleepStage.model, SleepStageEnum.light);
      expect(sleepStage.startTime, startTime);
      expect(sleepStage.endTime, endTime);
      expect(sleepStage.duration, duration);
    });

    test('should create test SleepStageDetails with factory constructor', () {
      final testStage = SleepStageDetails.withTest();

      expect(testStage.model, SleepStageEnum.light);
      expect(testStage.duration, 30);
      expect(testStage.endTime.difference(testStage.startTime).inMinutes, 30);
    });
  });

  group('SleepStageEnum Helper Functions', () {
    test('getModeByStage should return correct mode values', () {
      expect(getModeByStage(SleepStageEnum.light), 1);
      expect(getModeByStage(SleepStageEnum.deep), 2);
      expect(getModeByStage(SleepStageEnum.awake), 3);
      expect(getModeByStage(SleepStageEnum.notWorn), 4);
      expect(getModeByStage(SleepStageEnum.rem), 5);
      expect(getModeByStage(SleepStageEnum.unknown), -1);
    });

    test('getHeightByStage should return correct height values', () {
      expect(getHeightByStage(SleepStageEnum.deep), 6);
      expect(getHeightByStage(SleepStageEnum.light), 4);
      expect(getHeightByStage(SleepStageEnum.rem), 2);
      expect(getHeightByStage(SleepStageEnum.awake), 1);
      expect(getHeightByStage(SleepStageEnum.unknown), 7);
    });
  });

  group('Time Formatting Functions', () {
    test('formatTimeToHHMM should format time correctly', () {
      final time1 = DateTime(2024, 1, 1, 9, 5);
      final time2 = DateTime(2024, 1, 1, 14, 30);
      final time3 = DateTime(2024, 1, 1, 0, 0);

      expect(formatTimeToHHMM(time1), '09:05');
      expect(formatTimeToHHMM(time2), '14:30');
      expect(formatTimeToHHMM(time3), '00:00');
    });

    test('formatTimeMinute should format minutes correctly', () {
      expect(formatTimeMinute(0), '0m');
      expect(formatTimeMinute(30), '30m');
      expect(formatTimeMinute(60), '1h');
      expect(formatTimeMinute(90), '1h30m');
      expect(formatTimeMinute(120), '2h');
      expect(formatTimeMinute(150), '2h30m');
      expect(formatTimeMinute(-10), '0m');
    });
  });

  group('SleepStageChartLineStyle', () {
    test('should create line style with correct properties', () {
      const lineStyle = SleepStageChartLineStyle(width: 5.0, space: 3.0);

      expect(lineStyle.width, 5.0);
      expect(lineStyle.space, 3.0);
    });
  });

  group('SleepStageChartPaintStyle', () {
    test('should create paint style with correct properties', () {
      const paintStyle = SleepStageChartPaintStyle(
        color: Colors.red,
        strokeWidth: 2.0,
        style: PaintingStyle.stroke,
        strokeCap: StrokeCap.round,
      );

      expect(paintStyle.color, Colors.red);
      expect(paintStyle.strokeWidth, 2.0);
      expect(paintStyle.style, PaintingStyle.stroke);
      expect(paintStyle.strokeCap, StrokeCap.round);
    });
  });

  group('SleepStageChart Widget', () {
    testWidgets('should create SleepStageChart widget',
        (WidgetTester tester) async {
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
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SleepStageChart(
              details: sleepData,
              startTime: DateTime(2024, 1, 1, 22, 30),
              endTime: DateTime(2024, 1, 2, 6, 30),
              heightUnit: 0.6,
              xAxisTitleOffset: 40.0,
              xAxisTitleHeight: 30.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(SleepStageChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle tap interactions when hasIndicator is true',
        (WidgetTester tester) async {
      final sleepData = [
        SleepStageDetails(
          model: SleepStageEnum.light,
          startTime: DateTime(2024, 1, 1, 22, 30),
          endTime: DateTime(2024, 1, 1, 23, 30),
          duration: 60,
        ),
      ];

      bool callbackTriggered = false;
      SleepStageDetails? callbackStage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SleepStageChart(
              details: sleepData,
              startTime: DateTime(2024, 1, 1, 22, 30),
              endTime: DateTime(2024, 1, 2, 6, 30),
              heightUnit: 0.6,
              xAxisTitleOffset: 40.0,
              xAxisTitleHeight: 30.0,
              backgroundColor: Colors.white,
              hasIndicator: true,
              onIndicatorMoved: (stage) {
                callbackTriggered = true;
                callbackStage = stage;
              },
            ),
          ),
        ),
      );

      // Tap on the chart
      await tester.tap(find.byType(SleepStageChart));
      await tester.pump();

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should not handle interactions when hasIndicator is false',
        (WidgetTester tester) async {
      final sleepData = [
        SleepStageDetails(
          model: SleepStageEnum.light,
          startTime: DateTime(2024, 1, 1, 22, 30),
          endTime: DateTime(2024, 1, 1, 23, 30),
          duration: 60,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SleepStageChart(
              details: sleepData,
              startTime: DateTime(2024, 1, 1, 22, 30),
              endTime: DateTime(2024, 1, 2, 6, 30),
              heightUnit: 0.6,
              xAxisTitleOffset: 40.0,
              xAxisTitleHeight: 30.0,
              backgroundColor: Colors.white,
              hasIndicator: false,
            ),
          ),
        ),
      );

      expect(find.byType(SleepStageChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });

  group('Default Stage Colors', () {
    test('should have correct default colors for all stages', () {
      expect(stageColors[SleepStageEnum.light], const Color(0xFF54B0FF));
      expect(stageColors[SleepStageEnum.deep], const Color(0xFF4D58E7));
      expect(stageColors[SleepStageEnum.rem], const Color(0xFF82DDDD));
      expect(stageColors[SleepStageEnum.awake], const Color(0xFFFFA877));
    });
  });
}
