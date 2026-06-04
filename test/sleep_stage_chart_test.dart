import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

void main() {
  testWidgets('SleepStageChart renders correctly', (WidgetTester tester) async {
    final details = [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: DateTime(2023, 1, 1, 22, 0),
        end: DateTime(2023, 1, 1, 22, 30),
        titles: [],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: DateTime(2023, 1, 1, 22, 30),
        end: DateTime(2023, 1, 2, 0, 0),
        titles: [],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.deep,
        start: DateTime(2023, 1, 2, 0, 0),
        end: DateTime(2023, 1, 2, 2, 0),
        titles: [],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.rem,
        start: DateTime(2023, 1, 2, 2, 0),
        end: DateTime(2023, 1, 2, 4, 0),
        titles: [],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: DateTime(2023, 1, 2, 4, 0),
        end: DateTime(2023, 1, 2, 6, 0),
        titles: [],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: DateTime(2023, 1, 2, 6, 0),
        end: DateTime(2023, 1, 2, 6, 30),
        titles: [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepStageChart(
            data: details,
            dateFrom: DateTime(2023, 1, 1, 22, 0),
            dateTo: DateTime(2023, 1, 2, 7, 0),
            stageHeightRatio: 0.2,
            stageVerticalGapRatio: 0.05,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );

    expect(find.byType(SleepStageChart), findsOneWidget);
  });

  test('formatTimeMinute formats correctly', () {
    expect(formatTimeMinute(0), '0m');
    expect(formatTimeMinute(30), '30m');
    expect(formatTimeMinute(60), '1h');
    expect(formatTimeMinute(90), '1h30m');
    expect(formatTimeMinute(120), '2h');
  });
}
