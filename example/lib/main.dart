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
  List<SleepStageDetails> _generateSampleData() {
    final now = DateTime.now();
    // 晚上10:30开始睡觉
    final sleepStart = DateTime(now.year, now.month, now.day, 22, 30);

    return [
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: sleepStart,
        endTime: sleepStart.add(const Duration(minutes: 15)),
        duration: 15,
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 15)),
        endTime: sleepStart.add(const Duration(minutes: 75)),
        duration: 60,
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: sleepStart.add(const Duration(minutes: 75)),
        endTime: sleepStart.add(const Duration(minutes: 165)),
        duration: 90,
      ),
      SleepStageDetails(
        model: SleepStageEnum.rem,
        startTime: sleepStart.add(const Duration(minutes: 165)),
        endTime: sleepStart.add(const Duration(minutes: 225)),
        duration: 60,
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 225)),
        endTime: sleepStart.add(const Duration(minutes: 285)),
        duration: 60,
      ),
      SleepStageDetails(
        model: SleepStageEnum.deep,
        startTime: sleepStart.add(const Duration(minutes: 285)),
        endTime: sleepStart.add(const Duration(minutes: 375)),
        duration: 90,
      ),
      SleepStageDetails(
        model: SleepStageEnum.rem,
        startTime: sleepStart.add(const Duration(minutes: 375)),
        endTime: sleepStart.add(const Duration(minutes: 435)),
        duration: 60,
      ),
      SleepStageDetails(
        model: SleepStageEnum.light,
        startTime: sleepStart.add(const Duration(minutes: 435)),
        endTime: sleepStart.add(const Duration(minutes: 480)),
        duration: 45,
      ),
      SleepStageDetails(
        model: SleepStageEnum.awake,
        startTime: sleepStart.add(const Duration(minutes: 480)),
        endTime: sleepStart.add(const Duration(minutes: 510)),
        duration: 30,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sampleData = _generateSampleData();
    final startTime = sampleData.first.startTime;
    final endTime = sampleData.last.endTime;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 标题
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                '睡眠阶段图表示例',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// 睡眠阶段图表
            Container(
              alignment: Alignment.center,
              height: 300,
              child: SleepStageChart(
                startTime: startTime,
                endTime: endTime,
                details: sampleData,
                // Y轴上每个单位的高度比例，这里设置为总高度的 1/8
                heightUnit: 1 / 8.0,
                // X轴标签的垂直偏移量
                xAxisTitleOffset: 8.0,
                // 为X轴标签预留的高度
                xAxisTitleHeight: 15.0,
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
                onIndicatorMoved: (stage) {
                  // 可以在这里处理指示器移动事件
                  print('当前阶段: ${stage.model}');
                },
              ),
            ),

            /// 提示
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem('浅睡', stageColors[SleepStageEnum.light]!),
                  _buildLegendItem('深睡', stageColors[SleepStageEnum.deep]!),
                  _buildLegendItem('快速眼动', stageColors[SleepStageEnum.rem]!),
                  _buildLegendItem('清醒', stageColors[SleepStageEnum.awake]!),
                ],
              ),
            ),
          ],
        ),
      ),
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
