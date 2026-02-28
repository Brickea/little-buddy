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

    // MARK: - Skill clamping

    func testSkillPowerClamping() {
        let skill = Skill(name: "超强", type: .attack, power: 999, element: .fire)
        XCTAssertEqual(skill.power, 100)
    }

    func testSkillAccuracyClamping() {
        let skill = Skill(name: "必中", type: .attack, power: 50, accuracy: 200)
        XCTAssertEqual(skill.accuracy, 100)
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
