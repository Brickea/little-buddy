import XCTest
@testable import LittleBuddy

final class AICharacterServiceTests: XCTestCase {

    func testGenerateOpponentProducesValidCharacter() {
        let player = makeTestCharacter(element: .fire)
        let opponent = AICharacterService.generateOpponent(for: player)

        XCTAssertFalse(opponent.name.isEmpty)
        XCTAssertTrue(opponent.stats.isValid)
        XCTAssertFalse(opponent.skills.isEmpty)
        XCTAssertLessThanOrEqual(opponent.skills.count, Character.maxSkillCount)
        XCTAssertNoThrow(try DSLValidator.validate(opponent))
    }

    func testGenerateQuickCharacterProducesValidCharacter() {
        let character = AICharacterService.generateQuickCharacter()

        XCTAssertFalse(character.name.isEmpty)
        XCTAssertTrue(character.stats.isValid)
        XCTAssertFalse(character.skills.isEmpty)
        XCTAssertNoThrow(try DSLValidator.validate(character))
    }

    func testRandomStatsSumToTotalPoints() {
        // Run multiple times to catch edge cases in random generation
        for _ in 0..<100 {
            let stats = AICharacterService.randomStats()
            XCTAssertEqual(stats.sum, stats.totalPoints, "Stats sum (\(stats.sum)) should equal totalPoints (\(stats.totalPoints))")
            XCTAssertGreaterThan(stats.hp, 0)
            XCTAssertGreaterThan(stats.attack, 0)
            XCTAssertGreaterThan(stats.defense, 0)
            XCTAssertGreaterThan(stats.speed, 0)
        }
    }

    func testElementDetection() {
        XCTAssertEqual(AICharacterService.detectElement(from: "一个会喷火的机器人"), .fire)
        XCTAssertEqual(AICharacterService.detectElement(from: "蓝色水精灵"), .water)
        XCTAssertEqual(AICharacterService.detectElement(from: "会飞的风之鸟"), .wind)
        XCTAssertEqual(AICharacterService.detectElement(from: "岩石巨人"), .earth)
        XCTAssertEqual(AICharacterService.detectElement(from: "一个普通的怪兽"), .normal)
    }

    func testBodyTypeDetection() {
        XCTAssertEqual(AICharacterService.detectBodyType(from: "蓝色机器人"), .robot)
        XCTAssertEqual(AICharacterService.detectBodyType(from: "巨型恐龙"), .dragon)
        XCTAssertEqual(AICharacterService.detectBodyType(from: "可爱的小猫"), .animal)
        XCTAssertEqual(AICharacterService.detectBodyType(from: "超级战士"), .humanoid)
        XCTAssertEqual(AICharacterService.detectBodyType(from: "一个怪怪的东西"), .monster)
    }

    func testSkillGenerationIncludesBasicAttack() {
        for element in [Element.fire, .water, .wind, .earth, .normal] {
            let skills = AICharacterService.generateSkills(element: element)
            XCTAssertFalse(skills.isEmpty, "Skills should not be empty for element \(element)")
            XCTAssertTrue(
                skills.contains { $0.type == .attack && $0.cooldown == 0 },
                "Should include a basic attack with no cooldown for element \(element)"
            )
        }
    }

    func testSkillCountWithinLimit() {
        for element in [Element.fire, .water, .wind, .earth, .normal] {
            let skills = AICharacterService.generateSkills(element: element)
            XCTAssertLessThanOrEqual(skills.count, Character.maxSkillCount)
            XCTAssertGreaterThanOrEqual(skills.count, 2, "Should generate at least 2 skills")
        }
    }

    func testDescriptionBasedStatsAreValid() {
        let stats1 = AICharacterService.generateStats(description: "一个超级快的闪电猫")
        XCTAssertTrue(stats1.isValid)
        XCTAssertEqual(stats1.sum, 100)

        let stats2 = AICharacterService.generateStats(description: "坚硬的防御型岩石巨人")
        XCTAssertTrue(stats2.isValid)
        XCTAssertEqual(stats2.sum, 100)
    }

    // MARK: - Helpers

    private func makeTestCharacter(element: Element) -> Character {
        Character(
            name: "测试",
            ownerID: UUID(),
            appearance: CharacterAppearance(
                bodyType: .monster,
                primaryColor: "#FF0000",
                secondaryColor: "#000000",
                size: .medium,
                features: [],
                description: "test"
            ),
            stats: CharacterStats(hp: 40, attack: 25, defense: 20, speed: 15),
            element: element,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: [Skill(name: "测试攻击", type: .attack, power: 50)],
            generationPrompt: "test"
        )
    }
}
