import Foundation

/// AI 角色生成服务
/// Phase 0: 返回基于关键词解析的本地占位角色；Phase 1 接入真实 LLM API
struct AICharacterService {
    private let ownerID: UUID

    init(ownerID: UUID = UUID()) {
        self.ownerID = ownerID
    }

    /// 根据自然语言描述生成角色配置
    func generate(from description: String) async throws -> Character {
        // TODO: Phase 1 — 替换为真实 LLM API 调用
        // 当前实现：简单关键词匹配，生成占位角色
        let element = detectElement(from: description)
        let bodyType = detectBodyType(from: description)

        let appearance = CharacterAppearance(
            bodyType: bodyType,
            primaryColor: "#5B8CFF",
            secondaryColor: "#1C1C1C",
            size: .medium,
            features: [],
            description: description
        )

        let stats = CharacterStats(hp: 40, attack: 25, defense: 20, speed: 15, totalPoints: 100)

        let personality = CharacterPersonality(type: .balanced, description: "由描述自动生成")

        let attackSkill = Skill(
            name: "基础攻击",
            type: .attack,
            power: 40,
            element: element,
            cooldown: 0,
            accuracy: 95
        )

        return Character(
            name: extractName(from: description),
            ownerID: ownerID,
            appearance: appearance,
            stats: stats,
            element: element,
            personality: personality,
            skills: [attackSkill],
            generationPrompt: description
        )
    }

    // MARK: - Private helpers (Phase 0 keyword matching)

    private func detectElement(from text: String) -> Element {
        let lower = text.lowercased()
        if lower.contains("火") || lower.contains("喷火") || lower.contains("fire") { return .fire }
        if lower.contains("水") || lower.contains("water") { return .water }
        if lower.contains("风") || lower.contains("wind") { return .wind }
        if lower.contains("土") || lower.contains("earth") { return .earth }
        return .normal
    }

    private func detectBodyType(from text: String) -> CharacterAppearance.BodyType {
        let lower = text.lowercased()
        if lower.contains("机器人") || lower.contains("robot") { return .robot }
        if lower.contains("恐龙") || lower.contains("龙") { return .dragon }
        if lower.contains("动物") || lower.contains("猫") || lower.contains("狗") { return .animal }
        return .monster
    }

    private func extractName(from text: String) -> String {
        // 取前 8 个字符作为临时名称，Phase 1 中由 AI 生成
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let name = String(trimmed.prefix(8))
        return name.isEmpty ? "小伙伴" : name
    }
}
