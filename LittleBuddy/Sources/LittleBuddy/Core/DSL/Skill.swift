import Foundation

// MARK: - SkillEffect

/// 技能的附加效果
struct SkillEffect: Codable, Equatable {
    enum EffectType: String, Codable {
        case burn           = "burn"
        case freeze         = "freeze"      // 扩展包：自然之力
        case stun           = "stun"
        case poison         = "poison"
        case heal           = "heal"
        case defenseBoost   = "defense_boost"
        case attackBoost    = "attack_boost"
        case shield         = "shield"      // 扩展包：魔法
        case reflect        = "reflect"     // 扩展包：魔法
    }

    let type: EffectType
    /// 持续回合数（nil 表示立即生效）
    var duration: Int?
    /// 每回合持续伤害
    var damagePerTurn: Int?
    /// 属性倍率（用于 boost 类效果）
    var multiplier: Double?
    /// 治疗/护盾数值
    var amount: Int?
}

// MARK: - Skill

/// 角色技能定义
struct Skill: Codable, Identifiable, Equatable {
    enum SkillType: String, Codable {
        case attack  = "attack"
        case defense = "defense"
        case support = "support"
        case special = "special"
    }

    let id: UUID
    let name: String
    let type: SkillType
    /// 技能威力（0–100），纯防御/支援技能为 0
    let power: Int
    let element: Element
    /// 冷却回合数（0 表示无冷却）
    let cooldown: Int
    /// 命中率（0–100）
    let accuracy: Int
    let effect: SkillEffect?
    let description: String

    init(
        id: UUID = UUID(),
        name: String,
        type: SkillType,
        power: Int,
        element: Element = .normal,
        cooldown: Int = 0,
        accuracy: Int = 95,
        effect: SkillEffect? = nil,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.power = power.clamped(to: 0...100)
        self.element = element
        self.cooldown = max(0, cooldown)
        self.accuracy = accuracy.clamped(to: 0...100)
        self.effect = effect
        self.description = description
    }
}

// MARK: - Helpers

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
