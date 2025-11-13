import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

void main() {
  testWidgets('SleepStageChart renders correctly', (WidgetTester tester) async {
    final details = [
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: DateTime(2023, 1, 1, 22, 0),
        endTime: DateTime(2023, 1, 1, 22, 30),
        info: [],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: DateTime(2023, 1, 1, 22, 30),
        endTime: DateTime(2023, 1, 2, 0, 0),
        info: [],
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: DateTime(2023, 1, 2, 0, 0),
        endTime: DateTime(2023, 1, 2, 2, 0),
        info: [],
      ),
      SleepStageDetails(
        model: SleepStageEnum.rem,
        startTime: DateTime(2023, 1, 2, 2, 0),
        endTime: DateTime(2023, 1, 2, 4, 0),
        info: [],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: DateTime(2023, 1, 2, 4, 0),
        endTime: DateTime(2023, 1, 2, 6, 0),
        info: [],
      ),
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: DateTime(2023, 1, 2, 6, 0),
        endTime: DateTime(2023, 1, 2, 6, 30),
        info: [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepStageChart(
            details: details,
            startTime: DateTime(2023, 1, 1, 22, 0),
            endTime: DateTime(2023, 1, 2, 7, 0),
            heightUnitRatio: 0.1,
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

  test('getHeightByStage returns correct height', () {
    expect(getHeightByStage(SleepStageEnum.deep), 6);
    expect(getHeightByStage(SleepStageEnum.light), 4);
    expect(getHeightByStage(SleepStageEnum.rem), 2);
    expect(getHeightByStage(SleepStageEnum.awake), 1);
    expect(getHeightByStage(SleepStageEnum.unknown), 7);
  });
}
