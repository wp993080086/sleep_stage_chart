# 贡献指南

感谢您对 `sleep_stage_chart` 项目的关注！我们欢迎所有形式的贡献，包括但不限于：

- 🐛 Bug 报告
- 💡 功能建议
- 📝 文档改进
- 🔧 代码贡献
- 🧪 测试用例
- 🎨 UI/UX 改进

## 开始之前

### 环境要求

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0 <4.0.0
- Git
- 支持的IDE：VS Code、Android Studio、IntelliJ IDEA

### 项目设置

1. **Fork 项目**
   ```bash
   # 在 GitHub 上 fork 项目到你的账户
   ```

2. **克隆项目**
   ```bash
   git clone https://github.com/wp993080086/sleep_stage_chart.git
   cd sleep_stage_chart
   ```

3. **安装依赖**
   ```bash
   flutter pub get
   cd example
   flutter pub get
   cd ..
   ```

4. **验证环境**
   ```bash
   flutter doctor
   flutter analyze
   flutter test
   ```

## 贡献流程

### 1. 创建 Issue

在开始编码之前，请先创建一个 Issue 来描述你要解决的问题或添加的功能：

- 🐛 **Bug 报告**: 使用 Bug Report 模板
- 💡 **功能请求**: 使用 Feature Request 模板
- 📝 **文档改进**: 直接描述需要改进的内容

### 2. 创建分支

```bash
# 创建并切换到新分支
git checkout -b feature/your-feature-name
# 或
git checkout -b fix/your-bug-fix
```

分支命名规范：
- `feature/功能名称` - 新功能
- `fix/问题描述` - Bug 修复
- `docs/文档类型` - 文档更新
- `test/测试描述` - 测试改进
- `refactor/重构描述` - 代码重构

### 3. 编写代码

#### 代码规范

- **格式化**: 使用 `dart format .` 格式化代码
- **分析**: 确保 `flutter analyze` 无警告
- **注释**: 为公共API添加详细的文档注释
- **命名**: 使用清晰、描述性的变量和函数名

#### 代码风格

```dart
/// 睡眠阶段图表组件
/// 
/// 用于显示睡眠阶段数据的可视化图表，支持交互和自定义样式。
/// 
/// 示例用法：
/// ```dart
/// SleepStageChart(
///   details: sleepData,
///   startTime: startTime,
///   endTime: endTime,
///   hasIndicator: true,
/// )
/// ```
class SleepStageChart extends StatefulWidget {
  /// 睡眠阶段数据列表
  final List<SleepStageDetails> details;
  
  /// 图表开始时间
  final DateTime startTime;
  
  // ... 其他属性
}
```

#### 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```bash
# 功能添加
git commit -m "feat: 添加自定义颜色主题支持"

# Bug 修复
git commit -m "fix: 修复指示器位置计算错误"

# 文档更新
git commit -m "docs: 更新API文档和使用示例"

# 测试添加
git commit -m "test: 添加睡眠阶段枚举的单元测试"

# 代码重构
git commit -m "refactor: 优化图表绘制性能"
```

### 4. 编写测试

#### 单元测试

为新功能或修复的Bug添加相应的测试：

```dart
// test/sleep_stage_chart_test.dart
test('should calculate correct stage height', () {
  expect(getHeightByStage(SleepStageEnum.deep), 6);
  expect(getHeightByStage(SleepStageEnum.light), 4);
  expect(getHeightByStage(SleepStageEnum.rem), 2);
});
```

#### Widget 测试

```dart
testWidgets('should display sleep stage chart', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SleepStageChart(
        details: testSleepData,
        startTime: testStartTime,
        endTime: testEndTime,
      ),
    ),
  );
  
  expect(find.byType(SleepStageChart), findsOneWidget);
});
```

#### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/sleep_stage_chart_test.dart

# 生成测试覆盖率报告
flutter test --coverage
```

### 5. 更新文档

如果你的更改影响了API或用法，请更新相应的文档：

- `README.md` - 基本使用说明
- `doc/api.md` - 详细API文档
- `example/` - 示例代码
- 代码注释 - 内联文档

### 6. 提交 Pull Request

1. **推送分支**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **创建 PR**
   - 在 GitHub 上创建 Pull Request
   - 使用 PR 模板填写详细信息
   - 链接相关的 Issue

3. **PR 检查清单**
   - [ ] 代码已格式化 (`dart format .`)
   - [ ] 静态分析通过 (`flutter analyze`)
   - [ ] 所有测试通过 (`flutter test`)
   - [ ] 添加了必要的测试
   - [ ] 更新了相关文档
   - [ ] 遵循了提交规范

## 开发指南

### 项目结构

```
sleep_stage_chart/
├── lib/
│   ├── sleep_stage_chart.dart    # 主入口文件
│   └── src/
│       ├── main.dart             # 核心组件实现
│       └── model.dart            # 数据模型定义
├── example/                      # 示例应用
├── test/                         # 测试文件
├── doc/                          # 文档目录
├── .github/                      # GitHub 配置
└── pubspec.yaml                  # 项目配置
```

### 核心组件说明

#### SleepStageChart
主要的图表组件，负责：
- 渲染睡眠阶段数据
- 处理用户交互
- 管理指示器状态

#### SleepStageChartPainter
自定义画笔，负责：
- 绘制背景和网格
- 绘制睡眠阶段条形图
- 绘制连接线和指示器

#### SleepStageDetails
数据模型，包含：
- 睡眠阶段类型
- 时间范围
- 持续时间

### 调试技巧

#### 1. 使用 Flutter Inspector
```dart
// 在组件中添加调试信息
Widget build(BuildContext context) {
  debugPrint('SleepStageChart build: ${details.length} stages');
  return CustomPaint(/* ... */);
}
```

#### 2. 绘制调试信息
```dart
// 在 CustomPainter 中添加调试线条
void paint(Canvas canvas, Size size) {
  // 绘制调试网格
  if (kDebugMode) {
    _drawDebugGrid(canvas, size);
  }
  // ... 正常绘制逻辑
}
```

#### 3. 性能分析
```bash
# 分析应用性能
flutter run --profile

# 使用 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 常见问题

#### Q: 如何添加新的睡眠阶段类型？
A: 
1. 在 `SleepStageEnum` 中添加新枚举值
2. 更新 `getModeByStage` 和 `getHeightByStage` 函数
3. 在默认颜色映射中添加对应颜色
4. 添加相应的测试用例

#### Q: 如何优化图表性能？
A:
1. 使用 `RepaintBoundary` 包装图表
2. 实现 `shouldRepaint` 方法进行精确重绘控制
3. 对大量数据进行分页或虚拟化
4. 缓存计算结果

#### Q: 如何添加新的交互功能？
A:
1. 在 `SleepStageChart` 中添加相应的手势检测
2. 更新状态管理逻辑
3. 在 `SleepStageChartPainter` 中添加绘制逻辑
4. 添加回调函数支持

## 发布流程

### 版本号规范

遵循 [Semantic Versioning](https://semver.org/)：

- `MAJOR.MINOR.PATCH`
- `1.0.0` - 主要版本（破坏性更改）
- `0.1.0` - 次要版本（新功能）
- `0.0.1` - 补丁版本（Bug修复）

### 发布检查清单

- [ ] 所有测试通过
- [ ] 文档已更新
- [ ] CHANGELOG.md 已更新
- [ ] 版本号已更新
- [ ] 示例应用正常运行
- [ ] pub.dev 发布检查通过

## 社区准则

### 行为准则

我们致力于为每个人提供友好、安全和欢迎的环境，请遵循以下准则：

- 🤝 **尊重他人**: 尊重不同的观点和经验
- 💬 **建设性沟通**: 提供有用的反馈和建议
- 🎯 **专注主题**: 保持讨论与项目相关
- 📚 **乐于学习**: 保持开放的心态学习新知识
- 🚫 **零容忍**: 不容忍任何形式的骚扰或歧视

### 获得帮助

如果你需要帮助或有疑问：

1. 📖 查看文档和示例
2. 🔍 搜索现有的 Issues
3. 💬 创建新的 Issue 提问
4. 📧 联系维护者

### 认可贡献者

我们会在以下地方认可贡献者：

- README.md 贡献者列表
- 发布说明
- 项目网站（如果有）

## 许可证

通过贡献代码，你同意你的贡献将在与项目相同的许可证下授权。

---

再次感谢你的贡献！每一个贡献都让这个项目变得更好。🎉