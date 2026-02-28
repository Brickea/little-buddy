import Foundation

// MARK: - BattleTurnResult

struct BattleTurnResult {
    let attackerID: UUID
    let defenderID: UUID
    let skillUsed: Skill
    let damage: Int
    let effectApplied: SkillEffect?
    let isCritical: Bool
    let isElementalBonus: Bool
}

// MARK: - BattleState

enum BattleState {
    case ongoing
    case finished(winnerID: UUID)
}

// MARK: - BattleEngine

/// 本地回合制战斗引擎
struct BattleEngine {
    private static let elementalBonusMultiplier: Double = 1.5

    /// 计算一次技能使用的伤害值
    static func calculateDamage(
        attacker: Character,
        defender: Character,
        skill: Skill
    ) -> (damage: Int, isElementalBonus: Bool) {
        let base = Double(attacker.stats.attack) * Double(skill.power) / 100.0
        let reduced = base * (100.0 / Double(100 + defender.stats.defense))

        let isBonus = skill.element.strongAgainst == defender.element
        let multiplier = isBonus ? elementalBonusMultiplier : 1.0

        let finalDamage = max(1, Int((reduced * multiplier).rounded()))
        return (finalDamage, isBonus)
    }

    /// 决定先手顺序（速度高者先行动，速度相同时随机）
    static func turnOrder(character1: Character, character2: Character) -> (first: Character, second: Character) {
        if character1.stats.speed > character2.stats.speed {
            return (character1, character2)
        } else if character2.stats.speed > character1.stats.speed {
            return (character2, character1)
        } else {
            return Bool.random() ? (character1, character2) : (character2, character1)
        }
    }

    /// 执行一个回合的攻击，返回伤害结果
    static func executeTurn(
        attacker: Character,
        defender: Character,
        skill: Skill,
        currentHP: inout [UUID: Int]
    ) -> BattleTurnResult {
        let (damage, isBonus) = calculateDamage(
            attacker: attacker,
            defender: defender,
            skill: skill
        )
        currentHP[defender.id, default: defender.stats.hp] -= damage

        return BattleTurnResult(
            attackerID: attacker.id,
            defenderID: defender.id,
            skillUsed: skill,
            damage: damage,
            effectApplied: skill.effect,
            isCritical: false,  // TODO: Phase 1 中实现暴击系统
            isElementalBonus: isBonus
        )
    }

    /// 检查战斗是否结束
    static func checkState(currentHP: [UUID: Int]) -> BattleState {
        for (id, hp) in currentHP where hp <= 0 {
            // 找到 HP 为 0 的一方，另一方获胜
            let winnerID = currentHP.keys.first { $0 != id }
            if let winner = winnerID {
                return .finished(winnerID: winner)
            }
        }
        return .ongoing
    }
}
