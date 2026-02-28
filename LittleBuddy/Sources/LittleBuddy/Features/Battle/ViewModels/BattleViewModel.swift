import SwiftUI

// MARK: - BattlePhase

enum BattlePhase: Equatable {
    case ready
    case playerTurn
    case executing
    case opponentTurn
    case finished(won: Bool)
}

// MARK: - BattleLogEntry

struct BattleLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let isPlayerAction: Bool
    let isSystemMessage: Bool

    init(_ message: String, isPlayerAction: Bool = false, isSystemMessage: Bool = false) {
        self.message = message
        self.isPlayerAction = isPlayerAction
        self.isSystemMessage = isSystemMessage
    }
}

// MARK: - BattleViewModel

@MainActor
final class BattleViewModel: ObservableObject {
    // Published state
    @Published var phase: BattlePhase = .ready
    @Published var playerHP: Int
    @Published var opponentHP: Int
    @Published var battleLog: [BattleLogEntry] = []
    @Published var currentMessage: String = ""
    @Published var turnNumber: Int = 0

    // Character data
    let playerCharacter: Character
    let opponentCharacter: Character

    // Internal state
    private var currentHP: [UUID: Int]
    private var playerCooldowns: [UUID: Int] = [:]
    private var opponentCooldowns: [UUID: Int] = [:]
    private let playerGoesFirst: Bool

    init(player: Character, opponent: Character) {
        self.playerCharacter = player
        self.opponentCharacter = opponent
        self.playerHP = player.stats.hp
        self.opponentHP = opponent.stats.hp
        self.currentHP = [player.id: player.stats.hp, opponent.id: opponent.stats.hp]

        let order = BattleEngine.turnOrder(character1: player, character2: opponent)
        self.playerGoesFirst = order.first.id == player.id
    }

    // MARK: - Public API

    func startBattle() {
        guard phase == .ready else { return }
        turnNumber = 1
        let firstName = playerGoesFirst ? playerCharacter.name : opponentCharacter.name
        log("⚔️ 战斗开始！", isSystem: true)
        log("速度判定：「\(firstName)」先手！", isSystem: true)

        if playerGoesFirst {
            beginPlayerTurn()
        } else {
            beginOpponentTurn()
        }
    }

    func playerSelectSkill(_ skill: Skill) {
        guard phase == .playerTurn else { return }
        guard isSkillAvailable(skill) else { return }

        phase = .executing

        let result = BattleEngine.executeTurn(
            attacker: playerCharacter,
            defender: opponentCharacter,
            skill: skill,
            currentHP: &currentHP
        )
        opponentHP = max(0, currentHP[opponentCharacter.id] ?? 0)

        if skill.cooldown > 0 {
            playerCooldowns[skill.id] = skill.cooldown
        }

        var msg = "🎯 \(playerCharacter.name) 使用了「\(skill.name)」"
        msg += "，造成 \(result.damage) 点伤害！"
        if result.isElementalBonus { msg += " 💥元素克制！" }
        log(msg, isPlayer: true)
        currentMessage = msg

        if checkBattleEnd() { return }

        reduceCooldowns(&opponentCooldowns)
        scheduleOpponentTurn()
    }

    func isSkillAvailable(_ skill: Skill) -> Bool {
        playerCooldowns[skill.id, default: 0] <= 0
    }

    func cooldownRemaining(for skill: Skill) -> Int {
        playerCooldowns[skill.id, default: 0]
    }

    // MARK: - Private Methods

    private func beginPlayerTurn() {
        phase = .playerTurn
        currentMessage = "🎮 轮到你了！选择技能！"
    }

    private func beginOpponentTurn() {
        phase = .opponentTurn
        currentMessage = "🤔 对手正在思考..."
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            executeOpponentTurn()
        }
    }

    private func scheduleOpponentTurn() {
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            beginOpponentTurn()
        }
    }

    private func executeOpponentTurn() {
        let skill = selectAISkill()

        let result = BattleEngine.executeTurn(
            attacker: opponentCharacter,
            defender: playerCharacter,
            skill: skill,
            currentHP: &currentHP
        )
        playerHP = max(0, currentHP[playerCharacter.id] ?? 0)

        if skill.cooldown > 0 {
            opponentCooldowns[skill.id] = skill.cooldown
        }

        var msg = "💢 \(opponentCharacter.name) 使用了「\(skill.name)」"
        msg += "，造成 \(result.damage) 点伤害！"
        if result.isElementalBonus { msg += " 💥元素克制！" }
        log(msg, isPlayer: false)
        currentMessage = msg

        if checkBattleEnd() { return }

        reduceCooldowns(&playerCooldowns)
        turnNumber += 1
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            beginPlayerTurn()
        }
    }

    private func selectAISkill() -> Skill {
        let available = opponentCharacter.skills.filter {
            opponentCooldowns[$0.id, default: 0] <= 0
        }

        guard !available.isEmpty else {
            return Skill(
                name: "普通攻击",
                type: .attack,
                power: 20,
                element: opponentCharacter.element,
                description: "基础攻击"
            )
        }

        switch opponentCharacter.personality.type {
        case .aggressive:
            return available.max(by: { $0.power < $1.power }) ?? available[0]
        case .defensive:
            return available.first { $0.type == .defense }
                ?? available.first { $0.type == .support }
                ?? available[0]
        case .cunning:
            return available.first { $0.effect != nil } ?? available[0]
        case .balanced, .wild:
            return available.randomElement() ?? available[0]
        }
    }

    private func checkBattleEnd() -> Bool {
        let state = BattleEngine.checkState(currentHP: currentHP)
        if case .finished(let winnerID) = state {
            let won = winnerID == playerCharacter.id
            phase = .finished(won: won)
            if won {
                log("🎉 你赢了！太棒了！", isSystem: true)
                currentMessage = "🎉 你赢了！太棒了！"
            } else {
                log("😢 你输了……下次加油！", isSystem: true)
                currentMessage = "😢 你输了……下次再来！"
            }
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
