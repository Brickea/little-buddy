# Little Buddy 小伙伴 🥳

> 让小朋友用语言描述，AI 帮你造出专属小怪兽，然后对战！

## 项目简介

**Little Buddy** 是一款面向儿童的 AI 驱动 iOS 游戏。孩子只需用自然语言描述心目中的角色（机器人、小怪兽、超级英雄……），AI 便会将其"具象化"为一个拥有形象与技能的游戏角色，然后与其他小朋友创建的角色展开对战。

核心理念：**把小孩幻想中的东西，直接具象化、实体化。**

## 核心功能

| 功能 | 描述 |
|------|------|
| 🗣️ 自然语言建角 | 孩子与 AI 对话，描述角色外形、能力、性格 |
| 🤖 AI 角色生成 | 基于对话内容，通过 DSL 生成角色属性与技能 |
| ⚔️ 实时对战 | 两个角色展开回合制/实时对战 |
| 🎴 卡牌 & 3D 打印 | 将角色导出为实体卡片或 3D 打印文件 |
| 📦 扩展包 | 付费解锁新 DSL 元素（新技能、新属性、新类型） |

## 平台

- **当前目标**：iOS（iPhone / iPad）
- **未来扩展**：Android

## 文档导航

| 文档 | 说明 |
|------|------|
| [游戏设计文档 (GDD)](docs/GAME_DESIGN_DOCUMENT.md) | 核心玩法、角色系统、对战规则 |
| [技术架构](docs/TECHNICAL_ARCHITECTURE.md) | 系统架构、AI 集成、技术栈 |
| [角色 DSL 规范](docs/CHARACTER_DSL.md) | 角色定义语言规范 |
| [开发路线图](docs/ROADMAP.md) | 分阶段开发计划 |

## 快速开始（开发环境）

```bash
# 克隆仓库
git clone https://github.com/Brickea/little-buddy.git
cd little-buddy

# 打开 Xcode 项目
open LittleBuddy/LittleBuddy.xcodeproj
```

**依赖要求**
- Xcode 15+
- iOS 17+ SDK
- Swift 5.9+

## 商业模式

1. **App 内购买** — 扩展包、皮肤、道具
2. **实体周边** — 角色对战卡片（NFC/二维码）、3D 打印文件
3. **智能硬件**（未来）— 专属对战设备

## 贡献

欢迎提交 Issue 和 PR！请先阅读 [开发路线图](docs/ROADMAP.md) 了解当前优先级。

---

*"发挥想象力，练习表达" — 让每个小朋友的幻想成真 ✨*
