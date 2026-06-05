import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';
import 'colors.dart';

/// 睡眠阶段图表卡片
class SleepChartCard extends StatefulWidget {
  const SleepChartCard({super.key});

  @override
  State<SleepChartCard> createState() => _SleepChartCardState();
}

/// 睡眠阶段图表卡片状态管理类
class _SleepChartCardState extends State<SleepChartCard> {
  /// 生成示例睡眠数据
  List<SleepStageChartSegment> _generateSleepData() {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, 22, 30);

    // 辅助函数：创建时间段
    SleepStageChartSegment segment(
      SleepStageTypeEnum type,
      int startMin,
      int endMin,
      List<String> titles,
      String stageName,
    ) {
      final start = base.add(Duration(minutes: startMin));
      final end = base.add(Duration(minutes: endMin));
      return SleepStageChartSegment(
        type: type,
        start: start,
        end: end,
        titles: titles,
        subtitle:
            '$stageName · ${formatTimeToHHMM(start)} ~ ${formatTimeToHHMM(end)}',
      );
    }

    return [
      segment(SleepStageTypeEnum.awake, 0, 15, ['15', 'm'], '清醒'),
      segment(SleepStageTypeEnum.core, 15, 75, ['1', 'h'], '浅睡'),
      segment(SleepStageTypeEnum.deep, 75, 165, ['1', 'h', '30', 'm'], '深睡'),
      segment(SleepStageTypeEnum.rem, 165, 225, ['1', 'h'], 'REM'),
      segment(SleepStageTypeEnum.core, 225, 285, ['1', 'h'], '浅睡'),
      segment(SleepStageTypeEnum.deep, 285, 375, ['1', 'h', '30', 'm'], '深睡'),
      segment(SleepStageTypeEnum.rem, 375, 435, ['1', 'h'], 'REM'),
      segment(SleepStageTypeEnum.core, 435, 480, ['45', 'm'], '浅睡'),
      segment(SleepStageTypeEnum.awake, 480, 520, ['40', 'm'], '清醒'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sleepData = _generateSleepData();
    final sleepStart = sleepData.first.start;
    final sleepEnd = sleepData.last.end;
    final totalSleepTime = sleepEnd.difference(sleepStart);
    final hours = totalSleepTime.inHours;
    final minutes = totalSleepTime.inMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '昨晚睡眠',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$hours小时$minutes分钟',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF74B9FF).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '质量良好',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF74B9FF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 图表区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              alignment: Alignment.center,
              height: 200,
              child: SleepStageChart(
                data: sleepData,
                dateFrom: sleepStart,
                dateTo: sleepEnd,
                stageHeightRatio: 0.15,
                stageVerticalGapRatio: 0.1,
                backgroundColor: Colors.transparent,
                verticalLineVisible: false,
                horizontalNodes: const [0.0, 0.25, 0.5, 0.75, 1.0],
                tooltipOffset: 20,
                footerHeight: 28,
                connectorLineWidth: 1.0,
                footerChildren: [
                  _buildTimeLabel('22:30'),
                  _buildTimeLabel('07:10'),
                ],
                onStageChanged: (stage) {
                  debugPrint(
                      '${stage.type.title} ${stage.duration.inMinutes}分钟');
                },
              ),
            ),
          ),

          /// 图例
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('浅睡', SleepStageTypeEnum.core),
                _buildLegendItem('深睡', SleepStageTypeEnum.deep),
                _buildLegendItem('快速眼动', SleepStageTypeEnum.rem),
                _buildLegendItem('清醒', SleepStageTypeEnum.awake),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建时间标签
  Widget _buildTimeLabel(String time) {
    return Text(
      time,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.tertiaryText,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(String label, SleepStageTypeEnum type) {
    final color = defaultSleepStageColorsMap[type] ?? Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// 将日期时间转换为 HH:mm 格式,例如 14:30
String formatTimeToHHMM(DateTime time) {
  return '${time.hour}:${time.minute}';
}
