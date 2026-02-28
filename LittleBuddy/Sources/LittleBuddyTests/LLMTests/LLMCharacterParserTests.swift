import XCTest
@testable import LittleBuddy

final class LLMCharacterParserTests: XCTestCase {

    // MARK: - JSON Extraction

    func testExtractJSONFromMarkdownCodeBlock() throws {
        let response = """
        好的，这是你的角色：
        ```json
        {"name": "火焰龙", "element": "fire", "body_type": "dragon", "hp": 35, "attack": 30, "defense": 20, "speed": 15, "skills": []}
        ```
        """
        let json = try LLMCharacterParser.extractJSON(from: response)
        XCTAssertTrue(json.hasPrefix("{"))
        XCTAssertTrue(json.hasSuffix("}"))
    }

    func testExtractJSONFromPlainCodeBlock() throws {
        let response = """
        ```
        {"name": "test", "element": "water", "body_type": "monster", "hp": 40, "attack": 25, "defense": 20, "speed": 15, "skills": []}
        ```
        """
        let json = try LLMCharacterParser.extractJSON(from: response)
        XCTAssertTrue(json.contains("\"name\""))
    }

    func testExtractJSONFromRawJSON() throws {
        let response = """
        {"name": "岩石兽", "element": "earth", "body_type": "monster", "hp": 40, "attack": 20, "defense": 30, "speed": 10, "skills": []}
        """
        let json = try LLMCharacterParser.extractJSON(from: response)
        XCTAssertTrue(json.hasPrefix("{"))
    }

    func testExtractJSONFailsWithNoJSON() {
        let response = "这里没有任何 JSON 内容"
        XCTAssertThrowsError(try LLMCharacterParser.extractJSON(from: response))
    }

    // MARK: - Full Parsing

    func testParseValidLLMResponse() throws {
        let response = """
        {
          "name": "烈焰铁拳",
          "element": "fire",
          "body_type": "robot",
          "size": "large",
          "primary_color": "#FF4500",
          "personality": "aggressive",
          "personality_description": "勇猛无畏",
          "hp": 35,
          "attack": 30,
          "defense": 20,
          "speed": 15,
          "skills": [
            {
              "name": "铁锤击",
              "type": "attack",
              "power": 40,
              "element": "fire",
              "cooldown": 0,
              "accuracy": 95,
              "description": "基础攻击"
            },
            {
              "name": "喷火炮",
              "type": "attack",
              "power": 65,
              "element": "fire",
              "cooldown": 2,
              "accuracy": 85,
              "description": "强力火焰",
              "effect": {
                "type": "burn",
                "duration": 2,
                "damage_per_turn": 5
              }
            }
          ]
        }
        """

        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "一个会喷火的蓝色机器人"
        )

        XCTAssertEqual(character.name, "烈焰铁拳")
        XCTAssertEqual(character.element, .fire)
        XCTAssertEqual(character.appearance.bodyType, .robot)
        XCTAssertEqual(character.appearance.size, .large)
        XCTAssertEqual(character.personality.type, .aggressive)
        XCTAssertEqual(character.stats.sum, 100)
        XCTAssertTrue(character.stats.isValid)
        XCTAssertEqual(character.skills.count, 2)
        XCTAssertNoThrow(try DSLValidator.validate(character))
    }

    func testParseResponseWrappedInCodeBlock() throws {
        let response = """
        ```json
        {
          "name": "水灵灵",
          "element": "water",
          "body_type": "animal",
          "hp": 40,
          "attack": 20,
          "defense": 25,
          "speed": 15,
          "skills": [
            {"name": "水弹", "type": "attack", "power": 40, "cooldown": 0, "description": "水系攻击"}
          ]
        }
        ```
        """

        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "水精灵"
        )

        XCTAssertEqual(character.name, "水灵灵")
        XCTAssertEqual(character.element, .water)
        XCTAssertTrue(character.stats.isValid)
    }

    // MARK: - Stats Normalization

    func testNormalizeStatsAlreadyCorrect() {
        let stats = LLMCharacterParser.normalizeStats(hp: 40, attack: 25, defense: 20, speed: 15)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
    }

    func testNormalizeStatsFromOverflow() {
        let stats = LLMCharacterParser.normalizeStats(hp: 80, attack: 50, defense: 40, speed: 30)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
        XCTAssertGreaterThan(stats.hp, 0)
        XCTAssertGreaterThan(stats.attack, 0)
        XCTAssertGreaterThan(stats.defense, 0)
        XCTAssertGreaterThan(stats.speed, 0)
    }

    func testNormalizeStatsFromUnderflow() {
        let stats = LLMCharacterParser.normalizeStats(hp: 10, attack: 5, defense: 3, speed: 2)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
    }

    func testNormalizeStatsPreservesRatio() {
        let stats = LLMCharacterParser.normalizeStats(hp: 100, attack: 50, defense: 25, speed: 25)
        XCTAssertEqual(stats.sum, 100)
        // HP should still be the highest
        XCTAssertGreaterThan(stats.hp, stats.attack)
        XCTAssertGreaterThan(stats.attack, stats.defense)
    }

    // MARK: - Edge Cases

    func testParseWithUnknownEnumsFallsBackToDefaults() throws {
        let response = """
        {
          "name": "神秘兽",
          "element": "unknown_element",
          "body_type": "unknown_type",
          "personality": "unknown_personality",
          "hp": 40,
          "attack": 25,
          "defense": 20,
          "speed": 15,
          "skills": [
            {"name": "攻击", "type": "attack", "power": 40, "cooldown": 0}
          ]
        }
        """

        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "test"
        )

        // Should fall back to defaults
        XCTAssertEqual(character.element, .normal)
        XCTAssertEqual(character.appearance.bodyType, .monster)
        XCTAssertEqual(character.personality.type, .balanced)
        XCTAssertTrue(character.stats.isValid)
    }

    func testParseWithMissingOptionalFields() throws {
        let response = """
        {
          "name": "简单兽",
          "element": "fire",
          "body_type": "monster",
          "hp": 40,
          "attack": 25,
          "defense": 20,
          "speed": 15,
          "skills": [
            {"name": "攻击", "type": "attack", "power": 40, "cooldown": 0}
          ]
        }
        """

        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "test"
        )

        // Optional fields should use defaults
        XCTAssertEqual(character.appearance.size, .medium)
        XCTAssertEqual(character.personality.type, .balanced)
        XCTAssertTrue(character.stats.isValid)
    }

    // MARK: - Normalization Edge Cases

    func testNormalizeStatsWithZeroValues() {
        // Zero values should be clamped to 1
        let stats = LLMCharacterParser.normalizeStats(hp: 0, attack: 0, defense: 0, speed: 0)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
        XCTAssertGreaterThan(stats.hp, 0)
        XCTAssertGreaterThan(stats.attack, 0)
        XCTAssertGreaterThan(stats.defense, 0)
        XCTAssertGreaterThan(stats.speed, 0)
    }

    func testNormalizeStatsWithNegativeValues() {
        // Negative values should be clamped to 1
        let stats = LLMCharacterParser.normalizeStats(hp: -10, attack: -5, defense: -3, speed: -2)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
        XCTAssertGreaterThan(stats.hp, 0)
    }

    func testNormalizeStatsWithVeryLargeValues() {
        let stats = LLMCharacterParser.normalizeStats(hp: 1000, attack: 500, defense: 250, speed: 250)
        XCTAssertEqual(stats.sum, 100)
        XCTAssertTrue(stats.isValid)
    }

    // MARK: - Skill Parsing

    func testParseSkillWithEffect() throws {
        let response = """
        {
          "name": "效果兽",
          "element": "water",
          "body_type": "monster",
          "hp": 40,
          "attack": 25,
          "defense": 20,
          "speed": 15,
          "skills": [
            {
              "name": "治愈之泉",
              "type": "support",
              "power": 0,
              "element": "water",
              "cooldown": 3,
              "accuracy": 100,
              "description": "恢复生命",
              "effect": {
                "type": "heal",
                "amount": 30
              }
            }
          ]
        }
        """
        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "test"
        )
        XCTAssertEqual(character.skills.count, 1)
        XCTAssertNotNil(character.skills.first?.effect)
        XCTAssertEqual(character.skills.first?.effect?.type, .heal)
        XCTAssertEqual(character.skills.first?.effect?.amount, 30)
    }

    func testParseSkillWithUnknownEffectType() throws {
        let response = """
        {
          "name": "未知兽",
          "element": "fire",
          "body_type": "monster",
          "hp": 40,
          "attack": 25,
          "defense": 20,
          "speed": 15,
          "skills": [
            {
              "name": "攻击",
              "type": "attack",
              "power": 40,
              "cooldown": 0,
              "effect": {
                "type": "unknown_effect_type"
              }
            }
          ]
        }
        """
        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "test"
        )
        // Unknown effect type should result in nil effect
        XCTAssertNil(character.skills.first?.effect)
    }

    func testParseWithMaxSkillsTruncates() throws {
        let skillsJSON = (0..<6).map { i in
            """
            {"name": "技能\(i)", "type": "attack", "power": \(30 + i * 5), "cooldown": 0}
            """
        }.joined(separator: ",\n")

        let response = """
        {
          "name": "多技能兽",
          "element": "fire",
          "body_type": "monster",
          "hp": 40,
          "attack": 25,
          "defense": 20,
          "speed": 15,
          "skills": [\(skillsJSON)]
        }
        """
        let character = try LLMCharacterParser.parse(
            llmResponse: response,
            ownerID: UUID(),
            generationPrompt: "test"
        )
        XCTAssertLessThanOrEqual(character.skills.count, Character.maxSkillCount)
    }
}
