import 'package:flutter/material.dart';
import 'package:sleep_stage_chart_example/meditation_example.dart';
import 'package:sleep_stage_chart_example/sleep_example.dart';
import 'colors.dart';

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
      title: '睡眠阶段图表',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF74B9FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PingFang SC',
      ),
      home: const SleepChartDemoPage(),
    );
  }
}

/// 睡眠图表演示页面
class SleepChartDemoPage extends StatelessWidget {
  const SleepChartDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// 顶部标题栏
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            /// 内容区域
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),

                  /// 睡眠阶段图表卡片
                  const SleepChartCard(),

                  const SizedBox(height: 16),

                  /// 冥想图表卡片
                  const MeditationChartCard(),

                  /// 留白
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 主标题
          const Text(
            'sleep_stage_chart',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              letterSpacing: -0.5,
            ),
          ),

          /// 副标题
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '追踪您的睡眠质量和冥想时长',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText.withAlpha(205),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
