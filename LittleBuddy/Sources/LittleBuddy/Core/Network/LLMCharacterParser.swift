import Foundation

// MARK: - LLM Response JSON Models

/// LLM 返回的角色 JSON（snake_case 字段名）
struct LLMCharacterResponse: Decodable {
    let name: String
    let element: String
    let body_type: String
    let size: String?
    let primary_color: String?
    let personality: String?
    let personality_description: String?
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let skills: [LLMSkillResponse]
}

struct LLMSkillResponse: Decodable {
    let name: String
    let type: String        // "attack" | "defense" | "support"
    let power: Int
    let element: String?
    let cooldown: Int?
    let accuracy: Int?
    let description: String?
    let effect: LLMEffectResponse?
}

struct LLMEffectResponse: Decodable {
    let type: String        // "burn" | "heal" | "defense_boost" etc.
    let duration: Int?
    let damage_per_turn: Int?
    let multiplier: Double?
    let amount: Int?
}

// MARK: - LLMCharacterParser

enum LLMCharacterParserError: Error, LocalizedError {
    case jsonExtractionFailed
    case jsonDecodingFailed(Error)
    case invalidStatSum

    var errorDescription: String? {
        switch self {
        case .jsonExtractionFailed:
            return "无法从 AI 响应中提取 JSON"
        case .jsonDecodingFailed(let error):
            return "JSON 解析失败: \(error.localizedDescription)"
        case .invalidStatSum:
            return "属性点总和不合法"
        }
    }
}

/// 将 LLM 文本响应解析为 Character 模型
enum LLMCharacterParser {

    /// 从 LLM 的原始文本响应中解析出 Character
    static func parse(
        llmResponse: String,
        ownerID: UUID,
        generationPrompt: String
    ) throws -> Character {
        let jsonString = try extractJSON(from: llmResponse)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw LLMCharacterParserError.jsonExtractionFailed
        }

        let llmChar: LLMCharacterResponse
        do {
            llmChar = try JSONDecoder().decode(LLMCharacterResponse.self, from: jsonData)
        } catch {
            throw LLMCharacterParserError.jsonDecodingFailed(error)
        }

        return try buildCharacter(from: llmChar, ownerID: ownerID, generationPrompt: generationPrompt)
    }

    // MARK: - JSON Extraction

    /// 从 LLM 响应文本中提取 JSON 块（可能包裹在 ```json ... ``` 中）
    static func extractJSON(from text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 尝试提取 ```json ... ``` 包裹的代码块
        if let range = trimmed.range(of: "```json"),
           let endRange = trimmed.range(of: "```", range: range.upperBound..<trimmed.endIndex) {
            let jsonPart = trimmed[range.upperBound..<endRange.lowerBound]
            return String(jsonPart).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 尝试提取 ``` ... ``` 包裹的代码块
        if let range = trimmed.range(of: "```"),
           let endRange = trimmed.range(of: "```", range: range.upperBound..<trimmed.endIndex) {
            let jsonPart = trimmed[range.upperBound..<endRange.lowerBound]
            return String(jsonPart).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 尝试直接找第一个 { 和最后一个 }
        if let firstBrace = trimmed.firstIndex(of: "{"),
           let lastBrace = trimmed.lastIndex(of: "}") {
            return String(trimmed[firstBrace...lastBrace])
        }

        throw LLMCharacterParserError.jsonExtractionFailed
    }

    // MARK: - Character Building

    private static func buildCharacter(
        from llm: LLMCharacterResponse,
        ownerID: UUID,
        generationPrompt: String
    ) throws -> Character {
        let element = Element(rawValue: llm.element) ?? .normal
        let bodyType = CharacterAppearance.BodyType(rawValue: llm.body_type) ?? .monster
        let size = CharacterAppearance.Size(rawValue: llm.size ?? "medium") ?? .medium
        let personalityType = CharacterPersonality.PersonalityType(rawValue: llm.personality ?? "balanced") ?? .balanced
        let color = llm.primary_color ?? AICharacterService.elementColor(element)

        // 确保属性点总和 = 100
        var stats = normalizeStats(hp: llm.hp, attack: llm.attack, defense: llm.defense, speed: llm.speed)

        // 最终校验
        guard stats.isValid else {
            throw LLMCharacterParserError.invalidStatSum
        }

        let skills = llm.skills.prefix(Character.maxSkillCount).map { buildSkill(from: $0, characterElement: element) }

        let appearance = CharacterAppearance(
            bodyType: bodyType,
            primaryColor: color,
            secondaryColor: "#1C1C1C",
            size: size,
            features: [],
            description: generationPrompt
        )

        return Character(
            name: llm.name,
            ownerID: ownerID,
            appearance: appearance,
            stats: stats,
            element: element,
            personality: CharacterPersonality(
                type: personalityType,
                description: llm.personality_description ?? "由 AI 生成"
            ),
            skills: skills,
            generationPrompt: generationPrompt
        )
    }

    // MARK: - Stats Normalization

    /// 将 LLM 给出的属性点标准化为总和 = 100
    static func normalizeStats(hp: Int, attack: Int, defense: Int, speed: Int) -> CharacterStats {
        let rawHP = max(1, hp)
        let rawAtk = max(1, attack)
        let rawDef = max(1, defense)
        let rawSpd = max(1, speed)
        let rawSum = rawHP + rawAtk + rawDef + rawSpd

        let totalPoints = 100
        if rawSum == totalPoints {
            return CharacterStats(hp: rawHP, attack: rawAtk, defense: rawDef, speed: rawSpd, totalPoints: totalPoints)
        }

        // 按比例缩放
        let ratio = Double(totalPoints) / Double(rawSum)
        var nHP = max(1, Int(Double(rawHP) * ratio))
        let nAtk = max(1, Int(Double(rawAtk) * ratio))
        let nDef = max(1, Int(Double(rawDef) * ratio))
        let nSpd = max(1, Int(Double(rawSpd) * ratio))

        // 修正余数
        let diff = totalPoints - (nHP + nAtk + nDef + nSpd)
        nHP += diff

        return CharacterStats(hp: nHP, attack: nAtk, defense: nDef, speed: nSpd, totalPoints: totalPoints)
    }

    // MARK: - Skill Building

    private static func buildSkill(from llm: LLMSkillResponse, characterElement: Element) -> Skill {
        let skillType = Skill.SkillType(rawValue: llm.type) ?? .attack
        let skillElement = Element(rawValue: llm.element ?? characterElement.rawValue) ?? characterElement

        var effect: SkillEffect? = nil
        if let llmEffect = llm.effect,
           let effectType = SkillEffect.EffectType(rawValue: llmEffect.type) {
            effect = SkillEffect(
                type: effectType,
                duration: llmEffect.duration,
                damagePerTurn: llmEffect.damage_per_turn,
                multiplier: llmEffect.multiplier,
                amount: llmEffect.amount
            )
        }

        return Skill(
            name: llm.name,
            type: skillType,
            power: llm.power,
            element: skillElement,
            cooldown: llm.cooldown ?? 0,
            accuracy: llm.accuracy ?? 95,
            effect: effect,
            description: llm.description ?? ""
        )
    }
}
