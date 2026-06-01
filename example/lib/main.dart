import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';

/// 示例应用的主函数
void main() {
  runApp(const MyApp());
}

/// 应用程序的根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Stage Chart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sleep Stage Chart'),
    );
  }
}

/// 主页面组件，展示睡眠阶段图表
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// 页面标题
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 生成示例睡眠数据
  List<SleepStageChartSegment> _generateSleepSampleData() {
    final now = DateTime.now();
    // 晚上10:30开始睡觉
    final sleepStart = DateTime(now.year, now.month, now.day, 22, 30);

    return [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: sleepStart,
        end: sleepStart.add(const Duration(minutes: 15)),
        titles: ['清醒'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: sleepStart.add(const Duration(minutes: 15)),
        end: sleepStart.add(const Duration(minutes: 75)),
        titles: ['浅睡'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.deep,
        start: sleepStart.add(const Duration(minutes: 75)),
        end: sleepStart.add(const Duration(minutes: 165)),
        titles: ['深睡'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.rem,
        start: sleepStart.add(const Duration(minutes: 165)),
        end: sleepStart.add(const Duration(minutes: 225)),
        titles: ['REM'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: sleepStart.add(const Duration(minutes: 225)),
        end: sleepStart.add(const Duration(minutes: 285)),
        titles: ['浅睡'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.deep,
        start: sleepStart.add(const Duration(minutes: 285)),
        end: sleepStart.add(const Duration(minutes: 375)),
        titles: ['深睡'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.rem,
        start: sleepStart.add(const Duration(minutes: 375)),
        end: sleepStart.add(const Duration(minutes: 435)),
        titles: ['REM'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: sleepStart.add(const Duration(minutes: 435)),
        end: sleepStart.add(const Duration(minutes: 480)),
        titles: ['浅睡'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.awake,
        start: sleepStart.add(const Duration(minutes: 480)),
        end: sleepStart.add(const Duration(minutes: 520)),
        titles: ['清醒'],
      ),
    ];
  }

  /// 生成示例冥想数据
  List<SleepStageChartSegment> _generateMeditationSampleData() {
    final now = DateTime.now();
    // 早上06:00开始
    final dayStart = DateTime(now.year, now.month, now.day, 6, 0);

    return [
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: dayStart,
        end: dayStart.add(const Duration(minutes: 45)),
        titles: ['冥想'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: dayStart.add(const Duration(hours: 2)),
        end: dayStart.add(const Duration(hours: 3, minutes: 15)),
        titles: ['冥想'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: dayStart.add(const Duration(hours: 5)),
        end: dayStart.add(const Duration(hours: 5, minutes: 45)),
        titles: ['冥想'],
      ),
      SleepStageChartSegment(
        type: SleepStageTypeEnum.core,
        start: dayStart.add(const Duration(hours: 10, minutes: 45)),
        end: dayStart.add(const Duration(hours: 12, minutes: 50)),
        titles: ['冥想'],
      ),
    ];
  }

  /// 底部文本样式
  final _textStyle = const TextStyle(
    color: Color(0xFF666666),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 睡眠数据
    final sleepSample = _generateSleepSampleData();
    // 睡眠开始时间
    final sleepStartTime = sleepSample.first.start;
    // 睡眠结束时间
    final sleepEndTime = sleepSample.last.end;
    // 冥想数据
    final meditationSample = _generateMeditationSampleData();
    // 冥想开始时间
    final meditationStartTime = DateTime(now.year, now.month, now.day);
    // 冥想结束时间
    final meditationEndTime = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 标题
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '睡眠阶段图表样例',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                /// 睡眠阶段图表
                Container(
                  alignment: Alignment.center,
                  height: 300,
                  child: SleepStageChart(
                    // 详情数据
                    data: sleepSample,
                    // 开始时间
                    dateFrom: sleepStartTime,
                    // 结束时间
                    dateTo: sleepEndTime,
                    stageHeightRatio: 0.15,
                    stageVerticalGapRatio: 0.1,
                    // 图表的背景颜色
                    backgroundColor: Colors.transparent,
                    // 不绘制垂直线
                    verticalLineVisible: false,
                    // 回调事件
                    onChange: (stage) {
                      // 可以在这里处理指示器移动事件
                      print('当前阶段: ${stage.type}');
                    },
                    footerHeight: 32,
                    footerChild: [
                      Text(
                        '${sleepStartTime.hour}:${sleepStartTime.minute}',
                        style: _textStyle,
                      ),
                      Text(
                        '${sleepEndTime.hour}:${sleepEndTime.minute}',
                        style: _textStyle,
                      ),
                    ],
                  ),
                ),

                /// 图例提示
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(
                      '浅睡',
                      defaultSleepStageColorsMap[SleepStageTypeEnum.core]!,
                    ),
                    _buildLegendItem(
                      '深睡',
                      defaultSleepStageColorsMap[SleepStageTypeEnum.deep]!,
                    ),
                    _buildLegendItem(
                      '快速眼动',
                      defaultSleepStageColorsMap[SleepStageTypeEnum.rem]!,
                    ),
                    _buildLegendItem(
                      '清醒',
                      defaultSleepStageColorsMap[SleepStageTypeEnum.awake]!,
                    ),
                  ],
                ),

                /// 标题
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '冥想图表样例',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                /// 冥想图
                Container(
                  alignment: Alignment.center,
                  height: 300,
                  child: SleepStageChart(
                    stageHeightRatio: 0.25,
                    stageVerticalGapRatio: 0.0,
                    // 图表的背景颜色，带透明度
                    backgroundColor: Colors.transparent,
                    // 色块的圆角
                    borderRadius: 8,
                    // 是否显示垂直线
                    verticalLineVisible: true,
                    // 是否显示水平线
                    horizontalLineVisible: false,
                    // 列表，包含了每一段具体的睡眠数据
                    data: meditationSample,
                    // 整个图表的开始时间，用于计算X轴
                    dateFrom: meditationStartTime,
                    // 整个图表的结束时间
                    dateTo: meditationEndTime,
                    // 是否显示指示器
                    hasTooltipIndicator: true,
                    // 回调函数
                    onChange: (item) {
                      print('移动到：${item.type}');
                    },
                    allDayMode: true,
                    allDayColor: Colors.blue,
                    horizontalNodes: const [0.00, 0.25, 0.50, 0.75, 1.00],
                    // X轴底部标题高度
                    footerHeight: 32,
                    footerChild: ['00:00', '06:00', '12:00', '18:00', '00:00']
                        .map((v) => Text(v, style: _textStyle))
                        .toList(),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
