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
  List<SleepStageDetails> _generateSleepSampleData() {
    final now = DateTime.now();
    // 晚上10:30开始睡觉
    final sleepStart = DateTime(now.year, now.month, now.day, 22, 30);

    return [
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: sleepStart,
        endTime: sleepStart.add(const Duration(minutes: 15)),
        info: ['清醒'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 15)),
        endTime: sleepStart.add(const Duration(minutes: 75)),
        info: ['浅睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: sleepStart.add(const Duration(minutes: 75)),
        endTime: sleepStart.add(const Duration(minutes: 165)),
        info: ['深睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.rem,
        startTime: sleepStart.add(const Duration(minutes: 165)),
        endTime: sleepStart.add(const Duration(minutes: 225)),
        info: ['REM'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 225)),
        endTime: sleepStart.add(const Duration(minutes: 285)),
        info: ['浅睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: sleepStart.add(const Duration(minutes: 285)),
        endTime: sleepStart.add(const Duration(minutes: 375)),
        info: ['深睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.rem,
        startTime: sleepStart.add(const Duration(minutes: 375)),
        endTime: sleepStart.add(const Duration(minutes: 435)),
        info: ['REM'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 435)),
        endTime: sleepStart.add(const Duration(minutes: 480)),
        info: ['浅睡'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: sleepStart.add(const Duration(minutes: 480)),
        endTime: sleepStart.add(const Duration(minutes: 520)),
        info: ['清醒'],
      ),
    ];
  }

  /// 生成示例冥想数据
  List<SleepStageDetails> _generateMeditationSampleData() {
    final now = DateTime.now();
    // 早上06:00开始
    final dayStart = DateTime(now.year, now.month, now.day, 6, 0);

    return [
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
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: dayStart.add(const Duration(hours: 5)),
        endTime: dayStart.add(const Duration(hours: 5, minutes: 45)),
        info: ['冥想'],
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: dayStart.add(const Duration(hours: 10, minutes: 45)),
        endTime: dayStart.add(const Duration(hours: 12, minutes: 50)),
        info: ['冥想'],
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
    final sleepStartTime = sleepSample.first.startTime;
    // 睡眠结束时间
    final sleepEndTime = sleepSample.last.endTime;
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
                    // 开始时间
                    startTime: sleepStartTime,
                    // 结束时间
                    endTime: sleepEndTime,
                    // 详情数据
                    details: sleepSample,
                    // Y轴上每个单位的高度比例，这里设置为总高度的 1/8
                    heightUnitRatio: 1 / 8,
                    // 图表的背景颜色
                    backgroundColor: Colors.transparent,
                    // 几个间隔
                    horizontalLineCount: 4,
                    // 水平线样式
                    horizontalLineStyle: const SleepStageChartLineStyle(
                      width: 3,
                      space: 3,
                    ),
                    // 网格线样式
                    dividerPaintStyle: const SleepStageChartPaintStyle(
                      color: Color(0xFFB6BAD9),
                      strokeWidth: 0.5,
                      style: PaintingStyle.stroke,
                      strokeCap: StrokeCap.round,
                    ),
                    // 不绘制垂直线
                    showVerticalLine: false,
                    // 回调事件
                    onIndicatorMoved: (stage) {
                      // 可以在这里处理指示器移动事件
                      print('当前阶段: ${stage.model}');
                    },
                    xAxisBottomHeight: 32,
                    bottomChild: [
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
                      stageColors[SleepStageEnum.light]!,
                    ),
                    _buildLegendItem(
                      '深睡',
                      stageColors[SleepStageEnum.deep]!,
                    ),
                    _buildLegendItem(
                      '快速眼动',
                      stageColors[SleepStageEnum.rem]!,
                    ),
                    _buildLegendItem(
                      '清醒',
                      stageColors[SleepStageEnum.awake]!,
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
                    // Y轴上每个色块的高度比例
                    heightUnitRatio: 1 / 8,
                    // X轴底部标题高度
                    xAxisBottomHeight: 32,
                    // 图表的背景颜色，带透明度
                    backgroundColor: Colors.transparent,
                    // 色块的圆角
                    borderRadius: 8,
                    // 几个间隔
                    horizontalLineCount: 4,
                    // 是否显示垂直线
                    showVerticalLine: true,
                    // 是否显示水平线
                    showHorizontalLine: false,
                    // 网格线样式
                    dividerPaintStyle: const SleepStageChartPaintStyle(
                      color: Color(0xFFB6BAD9),
                      strokeWidth: 0.5,
                      style: PaintingStyle.stroke,
                      strokeCap: StrokeCap.round,
                    ),
                    // 列表，包含了每一段具体的睡眠数据
                    details: meditationSample,
                    // 整个图表的开始时间，用于计算X轴
                    startTime: meditationStartTime,
                    // 整个图表的结束时间
                    endTime: meditationEndTime,
                    // 全部使用一个颜色
                    stageColors: const {
                      SleepStageEnum.light: Color(0xFF43CAC4),
                      SleepStageEnum.deep: Color(0xFF43CAC4),
                      SleepStageEnum.rem: Color(0xFF43CAC4),
                      SleepStageEnum.awake: Color(0xFF43CAC4),
                    },
                    // 是否显示指示器
                    hasIndicator: true,
                    // 回调函数
                    onIndicatorMoved: (item) {
                      print('移动到：${item.model}');
                    },
                    allDayModel: true,
                    minuteInterval: 360,
                    bottomChild: ['00:00', '06:00', '12:00', '18:00', '00:00']
                        .map((v) => Text(v, style: _textStyle))
                        .toList(),
                  ),
                )
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
