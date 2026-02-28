# 角色 DSL 规范 (Character DSL Specification)

**版本**：v0.1  
**日期**：2026-02-28

---

## 概述

角色 DSL（领域特定语言）是 Little Buddy 游戏的核心数据模型。它将孩子的自然语言描述转化为结构化的角色配置，供游戏引擎解析和渲染。

**DSL 格式**：JSON（内部存储） / 自然语言（输入端）

---

## 1. 角色配置结构 (Character Schema)

```json
{
  "character": {
    "id": "uuid-v4",
    "name": "火焰铁拳",
    "owner_id": "user-uuid",
    "created_at": "2026-02-28T14:00:00Z",
    "version": "1.0",

    "appearance": {
      "body_type": "robot",
      "primary_color": "#FF4500",
      "secondary_color": "#1C1C1C",
      "size": "large",
      "features": ["iron_fist", "flame_emitter", "single_eye"],
      "style": "cartoon",
      "description": "一个蓝色的机器人，拳头像铁锤，眼睛里冒着火"
    },

    "stats": {
      "hp": 100,
      "attack": 35,
      "defense": 25,
      "speed": 20,
      "total_points": 100
    },

    "element": "fire",

    "personality": {
      "type": "aggressive",
      "description": "勇敢、直接，喜欢正面冲突"
    },

    "skills": [
      {
        "id": "skill-uuid-1",
        "name": "铁锤重击",
        "type": "attack",
        "power": 40,
        "element": "normal",
        "cooldown": 0,
        "accuracy": 95,
        "effect": null,
        "description": "用铁锤拳头猛击对手"
      },
      {
        "id": "skill-uuid-2",
        "name": "喷火炮",
        "type": "attack",
        "power": 60,
        "element": "fire",
        "cooldown": 2,
        "accuracy": 85,
        "effect": {
          "type": "burn",
          "duration": 2,
          "damage_per_turn": 5
        },
        "description": "从眼睛发射火焰，可能造成灼烧效果"
      },
      {
        "id": "skill-uuid-3",
        "name": "铁甲防御",
        "type": "defense",
        "power": 0,
        "element": "normal",
        "cooldown": 3,
        "accuracy": 100,
        "effect": {
          "type": "defense_boost",
          "multiplier": 1.5,
          "duration": 2
        },
        "description": "激活装甲，提升防御力"
      },
      {
        "id": "skill-uuid-4",
        "name": "紧急修复",
        "type": "support",
        "power": 0,
        "element": "normal",
        "cooldown": 4,
        "accuracy": 100,
        "effect": {
          "type": "heal",
          "amount": 30
        },
        "description": "自我修复，恢复 HP"
      }
    ],

    "metadata": {
      "dsl_version": "1.0",
      "extension_packs": ["base"],
      "generation_prompt": "一个会喷火的蓝色机器人，拳头是铁锤",
      "ai_model": "gpt-4o",
      "rating": null
    }
  }
}
```

---

## 2. 枚举值定义

### 2.1 身体类型 (`body_type`)

| 值 | 说明 | 需要扩展包 |
|----|------|-----------|
| `robot` | 机器人 | 基础包 |
| `monster` | 怪兽 | 基础包 |
| `animal` | 动物 | 基础包 |
| `humanoid` | 人形 | 基础包 |
| `dragon` | 龙类 | 扩展包：奇幻生物 |
| `elemental` | 元素生命体 | 扩展包：元素 |
| `vehicle` | 载具型 | 扩展包：机械 |

### 2.2 元素属性 (`element`)

| 值 | 说明 | 克制 | 需要扩展包 |
|----|------|------|-----------|
| `fire` | 火 | 克制风 | 基础包 |
| `water` | 水 | 克制火 | 基础包 |
| `wind` | 风 | 克制土 | 基础包 |
| `earth` | 土 | 克制水 | 基础包 |
| `lightning` | 雷 | 克制水 | 扩展包：自然之力 |
| `ice` | 冰 | 克制风 | 扩展包：自然之力 |
| `shadow` | 暗 | 克制光 | 扩展包：光暗 |
| `light` | 光 | 克制暗 | 扩展包：光暗 |
| `normal` | 无属性 | 无克制 | 基础包 |

### 2.3 技能类型 (`skill.type`)

| 值 | 说明 |
|----|------|
| `attack` | 攻击技能，造成伤害 |
| `defense` | 防御技能，提升防御或规避 |
| `support` | 支援技能，治疗或增益 |
| `special` | 特殊技能，特殊效果（基础包外需扩展包） |

### 2.4 技能效果 (`effect.type`)

| 值 | 说明 | 需要扩展包 |
|----|------|-----------|
| `burn` | 灼烧，每回合持续伤害 | 基础包 |
| `freeze` | 冻结，跳过行动 | 扩展包：自然之力 |
| `stun` | 眩晕，降低速度 | 基础包 |
| `poison` | 中毒，持续伤害 | 基础包 |
| `heal` | 治疗，恢复 HP | 基础包 |
| `defense_boost` | 防御提升 | 基础包 |
| `attack_boost` | 攻击提升 | 基础包 |
| `shield` | 护盾，抵消伤害 | 扩展包：魔法 |
| `reflect` | 反弹，将伤害反弹给对手 | 扩展包：魔法 |

### 2.5 角色性格 (`personality.type`)

| 值 | 说明 | AI 对战行为影响 |
|----|------|----------------|
| `aggressive` | 激进 | 优先使用高伤害技能 |
| `defensive` | 保守 | 优先使用防御技能 |
| `cunning` | 狡猾 | 优先使用状态效果技能 |
| `balanced` | 均衡 | 综合策略 |
| `wild` | 随机 | 随机选择技能 |

### 2.6 角色尺寸 (`appearance.size`)

| 值 | 说明 | 对战效果 |
|----|------|---------|
| `small` | 小型 | 速度 +10% |
| `medium` | 中型 | 无加成 |
| `large` | 大型 | 攻防 +10%，速度 -10% |
| `giant` | 巨型 | 攻防 +20%，速度 -20%（需扩展包） |

---

## 3. 属性点约束

```
stats.hp + stats.attack + stats.defense + stats.speed == stats.total_points
stats.total_points >= 100  // 基础值
stats.total_points <= 200  // 当前最大值（随等级提升）
```

---

## 4. DSL 扩展包机制

扩展包通过扩充**枚举值白名单**来实现，购买扩展包后，对应的枚举值在角色创建时变为可用。

```json
{
  "extension_pack": {
    "id": "natural_forces",
    "name": "自然之力",
    "version": "1.0",
    "unlocks": {
      "elements": ["lightning", "ice"],
      "skill_effects": ["freeze"],
      "body_features": ["thunder_wings", "ice_armor", "storm_cloak"]
    }
  }
}
```

---

## 5. AI 自然语言解析规则

AI 模型负责将孩子的自然语言描述映射到 DSL 字段：

| 描述关键词示例 | 映射字段 |
|---------------|---------|
| "蓝色的"、"红色的" | `appearance.primary_color` |
| "机器人"、"小怪兽"、"恐龙" | `appearance.body_type` |
| "会喷火"、"能放冰" | `element`, `skills[].element` |
| "超级快"、"速度很慢" | `stats.speed` 相对调整 |
| "很厉害的拳头" | `stats.attack` 提升 + 对应攻击技能 |
| "坚硬的盔甲" | `stats.defense` 提升 |
| "勇敢"、"胆小" | `personality.type` |

### 5.1 平衡约束

无论孩子如何描述，AI 必须遵守属性点总量上限，进行合理的属性分配：

```
// 伪代码
function allocateStats(description: NaturalLanguage): Stats {
    let emphasis = extractEmphasis(description) // ["attack", "speed"]
    return distributePoints(100, emphasis)       // 总计100点
}
```

---

## 6. 版本兼容性

- DSL `version` 字段用于前向兼容
- 旧版角色在新版 App 中自动迁移至最新 DSL 格式
- 迁移不会改变角色属性，只补充新增的可选字段
