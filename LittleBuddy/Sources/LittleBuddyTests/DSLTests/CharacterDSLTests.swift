import XCTest
@testable import LittleBuddy

final class CharacterDSLTests: XCTestCase {

    // MARK: - DSLValidator

    func testValidCharacterPassesValidation() throws {
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15)
        XCTAssertNoThrow(try DSLValidator.validate(character))
    }

    func testInvalidStatSumFailsValidation() {
        let character = makeCharacter(hp: 50, attack: 25, defense: 20, speed: 15) // sum = 110 ≠ 100
        XCTAssertThrowsError(try DSLValidator.validate(character)) { error in
            guard case DSLValidationError.invalidStatSum = error else {
                return XCTFail("Expected invalidStatSum error")
            }
        }
    }

    func testTooManySkillsFailsValidation() {
        let skills = (0..<5).map { i in
            Skill(name: "技能\(i)", type: .attack, power: 10, element: .normal)
        }
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15, skills: skills)
        XCTAssertThrowsError(try DSLValidator.validate(character)) { error in
            guard case DSLValidationError.tooManySkills = error else {
                return XCTFail("Expected tooManySkills error")
            }
        }
    }

    func testEmptyNameFailsValidation() {
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15, name: "   ")
        XCTAssertThrowsError(try DSLValidator.validate(character)) { error in
            guard case DSLValidationError.emptyName = error else {
                return XCTFail("Expected emptyName error")
            }
        }
    }

    func testMaxSkillCountIsRespected() {
        let skills = (0..<10).map { i in
            Skill(name: "技能\(i)", type: .attack, power: 10, element: .normal)
        }
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15, skills: skills)
        XCTAssertEqual(character.skills.count, Character.maxSkillCount)
    }

    // MARK: - Element Relationships

    func testFireStrongAgainstWind() {
        XCTAssertEqual(Element.fire.strongAgainst, .wind)
    }

    func testNormalHasNoAdvantage() {
        XCTAssertNil(Element.normal.strongAgainst)
    }

    func testBaseElementsAreBase() {
        for element in [Element.fire, .water, .wind, .earth, .normal] {
            XCTAssertTrue(element.isBase, "\(element) should be a base element")
        }
    }

    func testExtendedElementsAreNotBase() {
        for element in [Element.lightning, .ice, .shadow, .light] {
            XCTAssertFalse(element.isBase, "\(element) should require an extension pack")
        }
    }

    // MARK: - CharacterStats

    func testStatsSumValidation() {
        let validStats = CharacterStats(hp: 40, attack: 25, defense: 20, speed: 15, totalPoints: 100)
        XCTAssertTrue(validStats.isValid)

        let invalidStats = CharacterStats(hp: 50, attack: 25, defense: 20, speed: 15, totalPoints: 100)
        XCTAssertFalse(invalidStats.isValid)
    }

    // MARK: - DSLValidator – totalPointsOutOfRange

    func testTotalPointsBelowMinimumFailsValidation() {
        // totalPoints=50 is below minTotalPoints(100)
        let stats = CharacterStats(hp: 20, attack: 10, defense: 10, speed: 10, totalPoints: 50)
        let character = Character(
            name: "测试",
            ownerID: UUID(),
            appearance: CharacterAppearance(bodyType: .robot, primaryColor: "#FF0000", secondaryColor: "#000000", size: .medium, features: [], description: "测试"),
            stats: stats,
            element: .fire,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: [],
            generationPrompt: "test"
        )
        XCTAssertThrowsError(try DSLValidator.validate(character)) { error in
            guard case DSLValidationError.totalPointsOutOfRange = error else {
                return XCTFail("Expected totalPointsOutOfRange error, got \(error)")
            }
        }
    }

    func testTotalPointsAboveMaximumFailsValidation() {
        // totalPoints=250 is above maxTotalPoints(200)
        let stats = CharacterStats(hp: 100, attack: 60, defense: 50, speed: 40, totalPoints: 250)
        let character = Character(
            name: "测试",
            ownerID: UUID(),
            appearance: CharacterAppearance(bodyType: .robot, primaryColor: "#FF0000", secondaryColor: "#000000", size: .medium, features: [], description: "测试"),
            stats: stats,
            element: .fire,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: [],
            generationPrompt: "test"
        )
        XCTAssertThrowsError(try DSLValidator.validate(character)) { error in
            guard case DSLValidationError.totalPointsOutOfRange = error else {
                return XCTFail("Expected totalPointsOutOfRange error, got \(error)")
            }
        }
    }

    func testIsValidReturnsTrueForValidCharacter() {
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15)
        XCTAssertTrue(DSLValidator.isValid(character))
    }

    func testIsValidReturnsFalseForInvalidCharacter() {
        let character = makeCharacter(hp: 50, attack: 25, defense: 20, speed: 15, name: "   ")
        XCTAssertFalse(DSLValidator.isValid(character))
    }

    // MARK: - Element – Complete Relationship Chain

    func testAllElementStrongAgainstRelationships() {
        XCTAssertEqual(Element.fire.strongAgainst, .wind)
        XCTAssertEqual(Element.water.strongAgainst, .fire)
        XCTAssertEqual(Element.wind.strongAgainst, .earth)
        XCTAssertEqual(Element.earth.strongAgainst, .water)
        XCTAssertEqual(Element.lightning.strongAgainst, .water)
        XCTAssertEqual(Element.ice.strongAgainst, .wind)
        XCTAssertEqual(Element.shadow.strongAgainst, .light)
        XCTAssertEqual(Element.light.strongAgainst, .shadow)
        XCTAssertNil(Element.normal.strongAgainst)
    }

    func testAllElementEmojisAreNonEmpty() {
        for element in Element.allCases {
            XCTAssertFalse(element.emoji.isEmpty, "\(element) should have a non-empty emoji")
        }
    }

    func testAllElementDisplayNamesAreNonEmpty() {
        for element in Element.allCases {
            XCTAssertFalse(element.displayName.isEmpty, "\(element) should have a non-empty display name")
        }
    }

    // MARK: - CharacterAppearance.Size speed multiplier

    func testSizeSpeedMultiplier() {
        XCTAssertEqual(CharacterAppearance.Size.small.speedMultiplier, 1.1)
        XCTAssertEqual(CharacterAppearance.Size.medium.speedMultiplier, 1.0)
        XCTAssertEqual(CharacterAppearance.Size.large.speedMultiplier, 0.9)
        XCTAssertEqual(CharacterAppearance.Size.giant.speedMultiplier, 0.8)
    }

    // MARK: - Skill clamping

    func testSkillPowerClamping() {
        let skill = Skill(name: "超强", type: .attack, power: 999, element: .fire)
        XCTAssertEqual(skill.power, 100)
    }

    func testSkillPowerClampingNegative() {
        let skill = Skill(name: "弱击", type: .attack, power: -10, element: .fire)
        XCTAssertEqual(skill.power, 0)
    }

    func testSkillAccuracyClamping() {
        let skill = Skill(name: "必中", type: .attack, power: 50, accuracy: 200)
        XCTAssertEqual(skill.accuracy, 100)
    }

    func testSkillAccuracyClampingNegative() {
        let skill = Skill(name: "怎么也中不了", type: .attack, power: 50, accuracy: -10)
        XCTAssertEqual(skill.accuracy, 0)
    }

    func testSkillCooldownClampedToZero() {
        let skill = Skill(name: "负冷却", type: .attack, power: 50, cooldown: -5)
        XCTAssertEqual(skill.cooldown, 0)
    }

    func testSkillDefaultValues() {
        let skill = Skill(name: "测试", type: .attack, power: 50)
        XCTAssertEqual(skill.element, .normal)
        XCTAssertEqual(skill.cooldown, 0)
        XCTAssertEqual(skill.accuracy, 95)
        XCTAssertNil(skill.effect)
        XCTAssertEqual(skill.description, "")
    }

    // MARK: - Character init truncates skills

    func testCharacterInitTruncatesSkillsToMax() {
        let skills = (0..<6).map { i in
            Skill(name: "技能\(i)", type: .attack, power: 10, element: .normal)
        }
        let character = makeCharacter(hp: 40, attack: 25, defense: 20, speed: 15, skills: skills)
        XCTAssertEqual(character.skills.count, Character.maxSkillCount)
        // Should keep first 4 skills
        XCTAssertEqual(character.skills[0].name, "技能0")
        XCTAssertEqual(character.skills[3].name, "技能3")
    }

    // MARK: - Helpers

    private func makeCharacter(
        hp: Int,
        attack: Int,
        defense: Int,
        speed: Int,
        name: String = "测试角色",
        skills: [Skill] = []
    ) -> Character {
        Character(
            name: name,
            ownerID: UUID(),
            appearance: CharacterAppearance(
                bodyType: .robot,
                primaryColor: "#FF0000",
                secondaryColor: "#000000",
                size: .medium,
                features: [],
                description: "测试"
            ),
            stats: CharacterStats(hp: hp, attack: attack, defense: defense, speed: speed),
            element: .fire,
            personality: CharacterPersonality(type: .aggressive, description: ""),
            skills: skills,
            generationPrompt: "test"
        )
    }
}
