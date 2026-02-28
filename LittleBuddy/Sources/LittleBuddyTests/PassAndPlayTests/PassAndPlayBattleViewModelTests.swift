import XCTest
@testable import LittleBuddy

@MainActor
final class PassAndPlayBattleViewModelTests: XCTestCase {

    // MARK: - Initialization

    func testInitialPhaseIsReady() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.phase, .ready)
        XCTAssertEqual(vm.turnNumber, 0)
    }

    func testInitialHPMatchesCharacterStats() {
        let (p1, p2) = makeCharacters()
        let vm = PassAndPlayBattleViewModel(player1: p1, player2: p2)
        XCTAssertEqual(vm.player1HP, p1.stats.hp)
        XCTAssertEqual(vm.player2HP, p2.stats.hp)
    }

    // MARK: - Start Battle

    func testStartBattleSetsPassToPlayerPhase() {
        let vm = makeViewModel()
        vm.startBattle()
        // After starting, should be in .passToPlayer phase
        if case .passToPlayer(let player) = vm.phase {
            XCTAssertTrue(player == 1 || player == 2, "First player should be 1 or 2")
        } else {
            XCTFail("Expected passToPlayer phase, got \(vm.phase)")
        }
        XCTAssertEqual(vm.turnNumber, 1)
    }

    func testStartBattleOnlyOnceFromReady() {
        let vm = makeViewModel()
        vm.startBattle()
        let phaseAfterFirst = vm.phase
        vm.startBattle() // should be no-op
        XCTAssertEqual(vm.phase, phaseAfterFirst)
    }

    func testBattleLogPopulatedAfterStart() {
        let vm = makeViewModel()
        vm.startBattle()
        XCTAssertGreaterThanOrEqual(vm.battleLog.count, 2, "Should have at least battle start and turn order messages")
    }

    // MARK: - Player Ready

    func testPlayerReadyTransitionsToPlayerTurn() {
        let vm = makeViewModel()
        vm.startBattle()
        guard case .passToPlayer(let player) = vm.phase else {
            return XCTFail("Expected passToPlayer phase")
        }
        vm.playerReady()
        XCTAssertEqual(vm.phase, .playerTurn(player))
    }

    // MARK: - Skill Availability

    func testSkillIsAvailableInitially() {
        let vm = makeViewModel()
        let skill = Skill(name: "攻击", type: .attack, power: 50, element: .fire, cooldown: 0)
        XCTAssertTrue(vm.isSkillAvailable(skill, forPlayer: 1))
        XCTAssertTrue(vm.isSkillAvailable(skill, forPlayer: 2))
    }

    func testCooldownRemainingIsZeroInitially() {
        let vm = makeViewModel()
        let skill = Skill(name: "攻击", type: .attack, power: 50, element: .fire, cooldown: 2)
        XCTAssertEqual(vm.cooldownRemaining(for: skill, player: 1), 0)
    }

    // MARK: - Select Skill

    func testSelectSkillReducesOpponentHP() {
        let (p1, p2) = makeCharacters()
        let vm = PassAndPlayBattleViewModel(player1: p1, player2: p2)
        vm.startBattle()

        guard case .passToPlayer(let firstPlayer) = vm.phase else {
            return XCTFail("Expected passToPlayer phase")
        }
        vm.playerReady()

        let character = firstPlayer == 1 ? p1 : p2
        let skill = character.skills.first!

        vm.selectSkill(skill, byPlayer: firstPlayer)

        if firstPlayer == 1 {
            XCTAssertLessThan(vm.player2HP, p2.stats.hp, "Player 2 HP should be reduced")
        } else {
            XCTAssertLessThan(vm.player1HP, p1.stats.hp, "Player 1 HP should be reduced")
        }
    }

    func testSelectSkillIgnoredForWrongPlayer() {
        let (p1, p2) = makeCharacters()
        let vm = PassAndPlayBattleViewModel(player1: p1, player2: p2)
        vm.startBattle()

        guard case .passToPlayer(let firstPlayer) = vm.phase else {
            return XCTFail("Expected passToPlayer phase")
        }
        vm.playerReady()

        let wrongPlayer = firstPlayer == 1 ? 2 : 1
        let character = wrongPlayer == 1 ? p1 : p2
        let skill = character.skills.first!

        let hpBefore1 = vm.player1HP
        let hpBefore2 = vm.player2HP

        vm.selectSkill(skill, byPlayer: wrongPlayer)

        // HP should not change since wrong player tried to act
        XCTAssertEqual(vm.player1HP, hpBefore1)
        XCTAssertEqual(vm.player2HP, hpBefore2)
    }

    func testSelectSkillSetsSkillCooldown() {
        let (p1, p2) = makeCharactersWithCooldownSkills()
        let vm = PassAndPlayBattleViewModel(player1: p1, player2: p2)
        vm.startBattle()

        guard case .passToPlayer(let firstPlayer) = vm.phase else {
            return XCTFail("Expected passToPlayer phase")
        }
        vm.playerReady()

        let character = firstPlayer == 1 ? p1 : p2
        // Find a skill with cooldown > 0
        let cooldownSkill = character.skills.first { $0.cooldown > 0 }!

        vm.selectSkill(cooldownSkill, byPlayer: firstPlayer)

        XCTAssertFalse(vm.isSkillAvailable(cooldownSkill, forPlayer: firstPlayer))
        XCTAssertEqual(vm.cooldownRemaining(for: cooldownSkill, player: firstPlayer), cooldownSkill.cooldown)
    }

    func testBattleLogGrowsAfterSkillUse() {
        let (p1, p2) = makeCharacters()
        let vm = PassAndPlayBattleViewModel(player1: p1, player2: p2)
        vm.startBattle()

        guard case .passToPlayer(let firstPlayer) = vm.phase else {
            return XCTFail("Expected passToPlayer phase")
        }
        vm.playerReady()

        let logCountBefore = vm.battleLog.count
        let character = firstPlayer == 1 ? p1 : p2
        let skill = character.skills.first!

        vm.selectSkill(skill, byPlayer: firstPlayer)

        XCTAssertGreaterThan(vm.battleLog.count, logCountBefore)
    }

    // MARK: - Helpers

    private func makeViewModel() -> PassAndPlayBattleViewModel {
        let (p1, p2) = makeCharacters()
        return PassAndPlayBattleViewModel(player1: p1, player2: p2)
    }

    private func makeCharacters() -> (Character, Character) {
        let p1 = makeTestCharacter(name: "火焰战士", element: .fire, attack: 30, defense: 20, speed: 25)
        let p2 = makeTestCharacter(name: "水灵灵", element: .water, attack: 25, defense: 25, speed: 25)
        return (p1, p2)
    }

    private func makeCharactersWithCooldownSkills() -> (Character, Character) {
        let skills1 = [
            Skill(name: "火焰冲击", type: .attack, power: 40, element: .fire, cooldown: 0),
            Skill(name: "烈焰风暴", type: .attack, power: 70, element: .fire, cooldown: 2)
        ]
        let skills2 = [
            Skill(name: "水流弹", type: .attack, power: 40, element: .water, cooldown: 0),
            Skill(name: "巨浪冲击", type: .attack, power: 65, element: .water, cooldown: 2)
        ]
        let p1 = makeTestCharacter(name: "火焰战士", element: .fire, attack: 30, defense: 20, speed: 25, skills: skills1)
        let p2 = makeTestCharacter(name: "水灵灵", element: .water, attack: 25, defense: 25, speed: 25, skills: skills2)
        return (p1, p2)
    }

    private func makeTestCharacter(
        name: String,
        element: Element,
        attack: Int = 25,
        defense: Int = 25,
        speed: Int = 25,
        skills: [Skill]? = nil
    ) -> Character {
        let hp = 100 - attack - defense - speed
        let defaultSkills = [
            Skill(name: "攻击", type: .attack, power: 50, element: element, cooldown: 0)
        ]

        return Character(
            name: name,
            ownerID: UUID(),
            appearance: CharacterAppearance(
                bodyType: .monster,
                primaryColor: "#FF0000",
                secondaryColor: "#000000",
                size: .medium,
                features: [],
                description: "test"
            ),
            stats: CharacterStats(hp: hp, attack: attack, defense: defense, speed: speed),
            element: element,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: skills ?? defaultSkills,
            generationPrompt: "test"
        )
    }
}
