import 'package:flutter/material.dart';
import 'package:sleep_stage_chart/sleep_stage_chart.dart';
import 'colors.dart';

/// 冥想图表卡片
class MeditationChartCard extends StatefulWidget {
  const MeditationChartCard({super.key});

  @override
  State<MeditationChartCard> createState() => _MeditationChartCardState();
}

/// 冥想图表卡片状态管理类
class _MeditationChartCardState extends State<MeditationChartCard> {
  /// 生成示例冥想数据
  List<SleepStageChartSegment> _generateMeditationData() {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, 6, 0);

    // 辅助函数：创建冥想时间段
    SleepStageChartSegment segment(int startMin, int endMin) {
      final start = base.add(Duration(minutes: startMin));
      final end = base.add(Duration(minutes: endMin));
      return SleepStageChartSegment(
        type: SleepStageTypeEnum.inBed,
        start: start,
        end: end,
        titles: ['冥想'],
        subtitle: '冥想 · ${formatTimeToHHMM(start)} ~ ${formatTimeToHHMM(end)}',
      );
    }

    return [
      segment(0, 45), // 06:00 - 06:45
      segment(120, 195), // 08:00 - 09:15 (2h - 3h15m)
      segment(300, 345), // 11:00 - 11:45 (5h - 5h45m)
      segment(645, 770), // 16:45 - 18:50 (10h45m - 12h50m)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final meditationData = _generateMeditationData();
    final totalMinutes = meditationData.fold<int>(
      0,
      (sum, item) => sum + item.duration.inMinutes,
    );

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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日冥想',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '累计 ${formatTimeMinute(totalMinutes)}',
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
                    color: const Color(0xFF00B894).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '4 次',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00B894),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 图表区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              alignment: Alignment.center,
              height: 200,
              child: SleepStageChart(
                data: meditationData,
                dateFrom: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
                dateTo: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  23,
                  59,
                  59,
                ),
                stageHeightRatio: 0.25,
                stageVerticalGapRatio: 0,
                backgroundColor: Colors.transparent,
                borderRadius: 8,
                horizontalLineVisible: false,
                verticalNodes: const [0.0, 0.25, 0.5, 0.75, 1.0],
                verticalLineStyle: const SleepStageChartLineStyle(
                  width: 1,
                  space: 3,
                  dashLength: 3,
                  color: AppColors.divider,
                ),
                allDayMode: true,
                allDayColor: const Color(0xFF00B894),
                tooltipOffset: 15,
                footerHeight: 28,
                footerChildren: const [
                  _TimeLabel('00:00'),
                  _TimeLabel('06:00'),
                  _TimeLabel('12:00'),
                  _TimeLabel('18:00'),
                  _TimeLabel('24:00'),
                ],
              ),
            ),
          ),

          // 提示文字
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              0,
              16,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 16,
                  color: const Color(0xFF00B894).withAlpha(128),
                ),
                const SizedBox(width: 8),
                Text(
                  '保持正念，享受当下',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText.withAlpha(128),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 时间标签组件
class _TimeLabel extends StatelessWidget {
  final String text;

  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.tertiaryText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
