import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

void main() {
  testWidgets('SleepStageChart renders correctly', (WidgetTester tester) async {
    final details = [
      SleepStageDetails(
        type: SleepStageEnum.awake,
        start: DateTime(2023, 1, 1, 22, 0),
        end: DateTime(2023, 1, 1, 22, 30),
        titles: [],
      ),
      SleepStageDetails(
        type: SleepStageEnum.core,
        start: DateTime(2023, 1, 1, 22, 30),
        end: DateTime(2023, 1, 2, 0, 0),
        titles: [],
      ),
      SleepStageDetails(
        type: SleepStageEnum.deep,
        start: DateTime(2023, 1, 2, 0, 0),
        end: DateTime(2023, 1, 2, 2, 0),
        titles: [],
      ),
      SleepStageDetails(
        type: SleepStageEnum.rem,
        start: DateTime(2023, 1, 2, 2, 0),
        end: DateTime(2023, 1, 2, 4, 0),
        titles: [],
      ),
      SleepStageDetails(
        type: SleepStageEnum.core,
        start: DateTime(2023, 1, 2, 4, 0),
        end: DateTime(2023, 1, 2, 6, 0),
        titles: [],
      ),
      SleepStageDetails(
        type: SleepStageEnum.awake,
        start: DateTime(2023, 1, 2, 6, 0),
        end: DateTime(2023, 1, 2, 6, 30),
        titles: [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepStageChart(
            details: details,
            dateFrom: DateTime(2023, 1, 1, 22, 0),
            dateTo: DateTime(2023, 1, 2, 7, 0),
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
    expect(getHierarchyByStageType(SleepStageEnum.deep), 6);
    expect(getHierarchyByStageType(SleepStageEnum.core), 4);
    expect(getHierarchyByStageType(SleepStageEnum.rem), 2);
    expect(getHierarchyByStageType(SleepStageEnum.awake), 1);
    expect(getHierarchyByStageType(SleepStageEnum.unknown), 7);
  });
}
