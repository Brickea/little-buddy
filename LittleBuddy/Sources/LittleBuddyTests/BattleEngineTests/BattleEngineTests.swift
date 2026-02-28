import XCTest
@testable import LittleBuddy

final class BattleEngineTests: XCTestCase {

    // MARK: - Damage Calculation

    func testBasicDamageIsPositive() {
        let (attacker, defender) = makePair()
        let skill = Skill(name: "攻击", type: .attack, power: 50, element: .normal)
        let (damage, _) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: skill)
        XCTAssertGreaterThan(damage, 0)
    }

    func testElementalBonusIncreaseDamage() {
        let attacker = makeCharacter(element: .fire, attack: 50)
        let defender = makeCharacter(element: .wind, defense: 10)

        let skill = Skill(name: "火焰", type: .attack, power: 60, element: .fire)
        let (bonusDamage, isBonus) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: skill)

        let normalSkill = Skill(name: "普通", type: .attack, power: 60, element: .normal)
        let (normalDamage, _) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: normalSkill)

        XCTAssertTrue(isBonus)
        XCTAssertGreaterThan(bonusDamage, normalDamage)
    }

    func testNoElementalBonusWhenNoAdvantage() {
        let attacker = makeCharacter(element: .fire, attack: 50)
        let defender = makeCharacter(element: .fire, defense: 10)

        let skill = Skill(name: "火焰", type: .attack, power: 60, element: .fire)
        let (_, isBonus) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: skill)
        XCTAssertFalse(isBonus)
    }

    func testMinimumDamageIsOne() {
        // 攻击极低，防御极高，伤害至少为 1
        let attacker = makeCharacter(element: .normal, attack: 1)
        let defender = makeCharacter(element: .normal, defense: 99)
        let skill = Skill(name: "弱击", type: .attack, power: 1, element: .normal)
        let (damage, _) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: skill)
        XCTAssertGreaterThanOrEqual(damage, 1)
    }

    // MARK: - Turn Order

    func testFasterCharacterGoesFirst() {
        let fast = makeCharacter(element: .normal, speed: 80)
        let slow = makeCharacter(element: .normal, speed: 20)
        let (first, second) = BattleEngine.turnOrder(character1: fast, character2: slow)
        XCTAssertEqual(first.id, fast.id)
        XCTAssertEqual(second.id, slow.id)
    }

    func testTurnOrderReverseWhenSlowerIsFirst() {
        let fast = makeCharacter(element: .normal, speed: 80)
        let slow = makeCharacter(element: .normal, speed: 20)
        let (first, _) = BattleEngine.turnOrder(character1: slow, character2: fast)
        XCTAssertEqual(first.id, fast.id)
    }

    // MARK: - Battle State

    func testBattleEndsWhenHPReachesZero() {
        let (attacker, defender) = makePair()
        var hp: [UUID: Int] = [attacker.id: 100, defender.id: 0]
        let state = BattleEngine.checkState(currentHP: hp)
        guard case .finished(let winnerID) = state else {
            return XCTFail("Battle should be finished")
        }
        XCTAssertEqual(winnerID, attacker.id)
    }

    func testBattleOngoingWhenBothHaveHP() {
        let (attacker, defender) = makePair()
        let hp: [UUID: Int] = [attacker.id: 50, defender.id: 30]
        let state = BattleEngine.checkState(currentHP: hp)
        guard case .ongoing = state else {
            return XCTFail("Battle should be ongoing")
        }
    }

    func testExecuteTurnReducesDefenderHP() {
        let (attacker, defender) = makePair()
        let skill = Skill(name: "攻击", type: .attack, power: 50, element: .normal)
        var hp: [UUID: Int] = [attacker.id: 100, defender.id: 100]
        _ = BattleEngine.executeTurn(attacker: attacker, defender: defender, skill: skill, currentHP: &hp)
        XCTAssertLessThan(hp[defender.id]!, 100)
    }

    func testExecuteTurnReturnsDamageGreaterThanZero() {
        let (attacker, defender) = makePair()
        let skill = Skill(name: "攻击", type: .attack, power: 50, element: .normal)
        var hp: [UUID: Int] = [attacker.id: 100, defender.id: 100]
        let result = BattleEngine.executeTurn(attacker: attacker, defender: defender, skill: skill, currentHP: &hp)
        XCTAssertGreaterThan(result.damage, 0)
        XCTAssertEqual(result.attackerID, attacker.id)
        XCTAssertEqual(result.defenderID, defender.id)
    }

    func testExecuteTurnWithElementalBonus() {
        let attacker = makeCharacter(element: .fire, attack: 40)
        let defender = makeCharacter(element: .wind, defense: 20)
        let skill = Skill(name: "火焰", type: .attack, power: 60, element: .fire)
        var hp: [UUID: Int] = [attacker.id: 100, defender.id: 100]
        let result = BattleEngine.executeTurn(attacker: attacker, defender: defender, skill: skill, currentHP: &hp)
        XCTAssertTrue(result.isElementalBonus)
    }

    func testBattleEndsWhenHPGoesNegative() {
        let (attacker, defender) = makePair()
        let hp: [UUID: Int] = [attacker.id: 50, defender.id: -10]
        let state = BattleEngine.checkState(currentHP: hp)
        guard case .finished(let winnerID) = state else {
            return XCTFail("Battle should be finished when HP is negative")
        }
        XCTAssertEqual(winnerID, attacker.id)
    }

    func testZeroPowerSkillDoesMinimumDamage() {
        let (attacker, defender) = makePair()
        let skill = Skill(name: "无力", type: .attack, power: 0, element: .normal)
        let (damage, _) = BattleEngine.calculateDamage(attacker: attacker, defender: defender, skill: skill)
        // Even with 0 power, minimum damage should be 1
        XCTAssertGreaterThanOrEqual(damage, 1)
    }

    // MARK: - Helpers

    private func makePair() -> (Character, Character) {
        (makeCharacter(element: .fire, attack: 30, defense: 20, speed: 25),
         makeCharacter(element: .wind, attack: 25, defense: 15, speed: 20))
    }

    private func makeCharacter(
        element: Element,
        attack: Int = 30,
        defense: Int = 20,
        speed: Int = 25
    ) -> Character {
        let remaining = 100 - attack - defense - speed
        return Character(
            name: "测试角色",
            ownerID: UUID(),
            appearance: CharacterAppearance(
                bodyType: .monster,
                primaryColor: "#00FF00",
                secondaryColor: "#000000",
                size: .medium,
                features: [],
                description: "test"
            ),
            stats: CharacterStats(hp: remaining, attack: attack, defense: defense, speed: speed),
            element: element,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: [],
            generationPrompt: "test"
        )
    }
}
