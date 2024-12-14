# PortyChat - macOS串口通信工具

## 项目概述
PortyChat 是一个简洁易用的 macOS 串口通信工具，主要用于串口数据的收发和管理。该工具支持多种波特率设置，支持文本和十六进制两种数据格式，并提供历史记录功能。

## 功能特性

### 1. 串口管理
- [x] 自动检测系统可用串口
- [x] 动态刷新串口列表
- [x] 支持常用波特率选择（如9600、115200等）
- [x] 串口连接状态显示
- [x] 连接状态实时反馈

### 2. 数据收发
- [x] 支持文本模式和十六进制模式
- [x] 实时数据接收显示
- [x] 数据发送功能
- [x] 一键清除收发数据
- [x] 自动滚动功能
- [x] HEX模式下支持自动换行
- [x] HEX模式下同时显示原始数据和解析数据
- [x] 平滑的界面切换动画

### 3. 历史记录
- [ ] 保存发送的历史消息
- [ ] 支持快速重发历史消息
- [ ] 历史记录管理（删除、清空等）

## 技术架构

### 开发环境
- macOS 13.0+
- Swift 5.0
- SwiftUI
- Xcode 14.0+

### 核心模块
1. **串口通信模块**
   - 使用ORSSerial框架处理串口通信
   - 支持异步数据收发
   - 支持多种数据格式转换
   - 支持数据统计和监控
   - 支持超时和异常处理
   
2. **界面模块**
   - 使用SwiftUI构建现代化界面
   - 采用MVVM架构模式
   - 流畅的动画效果
   - 响应式布局
   - 支持键盘快捷操作
   - 状态实时反馈
   
3. **数据处理模块**
   - 支持文本/HEX格式转换
   - 支持数据过滤和格式化
   - 支持自动换行功能
   - 支持数据验证
   - 支持缓冲区管理
   - 支持大数据处理

## 界面设计
应用采用三标签式布局：

1. **首页（串口通信）**
   - [x] 串口设置区域（固定布局）
   - [x] 数据接收区域（动态布局）
   - [x] 数据发送区域（固定高度）
   - [x] 快捷操作按钮
   - [x] HEX模式下的双窗口显示

2. **历史记录**
   - [ ] 历史消息列表
   - [ ] 消息管理功能

3. **设置**
   - [ ] 预留功能配置界面

## 开发计划

### 第一阶段：基础功能实现 ✓
- [x] 创建项目基础架构
- [x] 实现串口检测和选择
- [x] 实现基本的数据收发功能
- [x] 完成主界面UI设计
- [x] 实现HEX模式切换
- [x] 优化界面动画效果

### 第二阶段：功能完善
- [ ] 实现历史记录功能
- [ ] 添加数据格式转换
- [ ] 优化UI交互体验
- [ ] 添加更多串口配置选项
- [ ] 添加数据统计显示（收发字节计数）
- [ ] 发送区域字符计数显示
- [ ] HEX模式下的数据格式验证
- [ ] 串口连接超时处理
- [ ] 添加常用操作快捷键支持
- [ ] 数据缓冲区管理（防止内存溢出）
- [ ] 完整的串口参数配置
- [ ] 更详细的状态指示器

### 第三阶段：优化和测试
- [ ] 性能优化
- [ ] 异常处理
- [ ] 用户体验改进
- [ ] 添加自动重连机制
- [ ] 内存使用优化
- [ ] 大数据传输测试
- [ ] 稳定性测��
- [ ] 用户操作习惯分析

## 使用说明
1. 串口连接
   - 从下拉列表选择串口设备
   - 选择合适的波特率
   - 点击"连接"按钮
   
2. 数据收发
   - 在发送区域输入要发送的数据
   - 可选择HEX模式发送
   - 接收区域实时显示收到的数据
   - HEX模式下可查看原始数据

3. 界面控制
   - 自动滚动：控制是否自动滚动到最新数据
   - 自动换行：HEX模式下控制数据显示格式
   - 清除按钮：一键清空显示区域

## 注意事项
1. 使用前请确保系统已正确识别串口设备
2. 建议在发送大量数据时先进行小数据测试
3. 使用十六进制模式时注意数据格式正确性

## 贡献指南
欢迎提交问题和建议，帮助改进项目。

## 许可证
MIT License