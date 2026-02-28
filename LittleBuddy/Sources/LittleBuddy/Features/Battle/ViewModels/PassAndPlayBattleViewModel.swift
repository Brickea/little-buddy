import SwiftUI

// MARK: - PassAndPlayBattlePhase

enum PassAndPlayBattlePhase: Equatable {
    case ready
    case passToPlayer(Int)       // 提示将设备交给指定玩家
    case playerTurn(Int)         // 玩家 1 或 2 选择技能
    case executing
    case finished(winnerPlayer: Int) // 1 or 2
}

// MARK: - PassAndPlayBattleViewModel

@MainActor
final class PassAndPlayBattleViewModel: ObservableObject {
    @Published var phase: PassAndPlayBattlePhase = .ready
    @Published var player1HP: Int
    @Published var player2HP: Int
    @Published var battleLog: [BattleLogEntry] = []
    @Published var currentMessage: String = ""
    @Published var turnNumber: Int = 0

    let player1Character: Character
    let player2Character: Character

    private var currentHP: [UUID: Int]
    private var player1Cooldowns: [UUID: Int] = [:]
    private var player2Cooldowns: [UUID: Int] = [:]
    private let firstPlayer: Int // 1 or 2

    init(player1: Character, player2: Character) {
        self.player1Character = player1
        self.player2Character = player2
        self.player1HP = player1.stats.hp
        self.player2HP = player2.stats.hp
        self.currentHP = [player1.id: player1.stats.hp, player2.id: player2.stats.hp]

        let order = BattleEngine.turnOrder(character1: player1, character2: player2)
        self.firstPlayer = order.first.id == player1.id ? 1 : 2
    }

    // MARK: - Public API

    func startBattle() {
        guard phase == .ready else { return }
        turnNumber = 1
        let firstName = firstPlayer == 1 ? player1Character.name : player2Character.name
        log("⚔️ 战斗开始！", isSystem: true)
        log("速度判定：「\(firstName)」（玩家 \(firstPlayer)）先手！", isSystem: true)

        phase = .passToPlayer(firstPlayer)
    }

    func playerReady() {
        if case .passToPlayer(let player) = phase {
            phase = .playerTurn(player)
            let name = player == 1 ? player1Character.name : player2Character.name
            currentMessage = "🎮 玩家 \(player)（\(name)），选择技能！"
        }
    }

    func selectSkill(_ skill: Skill, byPlayer player: Int) {
        guard case .playerTurn(let currentPlayer) = phase, currentPlayer == player else { return }
        guard isSkillAvailable(skill, forPlayer: player) else { return }

        phase = .executing

        let (attacker, defender) = player == 1
            ? (player1Character, player2Character)
            : (player2Character, player1Character)

        let result = BattleEngine.executeTurn(
            attacker: attacker,
            defender: defender,
            skill: skill,
            currentHP: &currentHP
        )

        // 更新 HP
        player1HP = max(0, currentHP[player1Character.id] ?? 0)
        player2HP = max(0, currentHP[player2Character.id] ?? 0)

        // 设置冷却
        if skill.cooldown > 0 {
            if player == 1 {
                player1Cooldowns[skill.id] = skill.cooldown
            } else {
                player2Cooldowns[skill.id] = skill.cooldown
            }
        }

        // 日志
        let emoji = player == 1 ? "🔵" : "🔴"
        var msg = "\(emoji) \(attacker.name) 使用了「\(skill.name)」"
        msg += "，造成 \(result.damage) 点伤害！"
        if result.isElementalBonus { msg += " 💥元素克制！" }
        log(msg, isPlayer: player == 1)
        currentMessage = msg

        // 检查战斗结束
        if checkBattleEnd() { return }

        // 减少对方冷却
        if player == 1 {
            reduceCooldowns(&player2Cooldowns)
        } else {
            reduceCooldowns(&player1Cooldowns)
        }

        // 切换到下一个玩家
        let nextPlayer = player == 1 ? 2 : 1
        if nextPlayer == firstPlayer { turnNumber += 1 }

        // 延迟后显示传屏提示
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            phase = .passToPlayer(nextPlayer)
        }
    }

    func isSkillAvailable(_ skill: Skill, forPlayer player: Int) -> Bool {
        let cooldowns = player == 1 ? player1Cooldowns : player2Cooldowns
        return cooldowns[skill.id, default: 0] <= 0
    }

    func cooldownRemaining(for skill: Skill, player: Int) -> Int {
        let cooldowns = player == 1 ? player1Cooldowns : player2Cooldowns
        return cooldowns[skill.id, default: 0]
    }

    // MARK: - Private Methods

    private func checkBattleEnd() -> Bool {
        let state = BattleEngine.checkState(currentHP: currentHP)
        if case .finished(let winnerID) = state {
            let winnerPlayer = winnerID == player1Character.id ? 1 : 2
            phase = .finished(winnerPlayer: winnerPlayer)
            let winnerName = winnerPlayer == 1 ? player1Character.name : player2Character.name
            log("🎉 玩家 \(winnerPlayer)（\(winnerName)）赢了！", isSystem: true)
            currentMessage = "🎉 玩家 \(winnerPlayer) 赢了！"
            return true
        }
        return false
    }

    private func log(_ message: String, isPlayer: Bool = false, isSystem: Bool = false) {
        battleLog.append(BattleLogEntry(message, isPlayerAction: isPlayer, isSystemMessage: isSystem))
    }

    private func reduceCooldowns(_ cooldowns: inout [UUID: Int]) {
        for key in cooldowns.keys {
            cooldowns[key] = max(0, (cooldowns[key] ?? 0) - 1)
        }
    }
}
