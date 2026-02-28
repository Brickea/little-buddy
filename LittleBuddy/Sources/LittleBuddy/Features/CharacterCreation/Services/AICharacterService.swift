import Foundation

/// AI 角色生成服务
/// Phase 0: 基于关键词解析的本地生成；Phase 1 接入真实 LLM API
struct AICharacterService {
    private let ownerID: UUID

    init(ownerID: UUID = UUID()) {
        self.ownerID = ownerID
    }

    /// 根据自然语言描述生成角色配置
    func generate(from description: String) async throws -> Character {
        // TODO: Phase 1 — 替换为真实 LLM API 调用
        let element = Self.detectElement(from: description)
        let bodyType = Self.detectBodyType(from: description)
        let personality = Self.detectPersonality(from: description)
        let size = Self.detectSize(from: description)
        let stats = Self.generateStats(description: description)
        let skills = Self.generateSkills(element: element)
        let name = Self.extractName(from: description)

        let appearance = CharacterAppearance(
            bodyType: bodyType,
            primaryColor: Self.elementColor(element),
            secondaryColor: "#1C1C1C",
            size: size,
            features: [],
            description: description
        )

        return Character(
            name: name,
            ownerID: ownerID,
            appearance: appearance,
            stats: stats,
            element: element,
            personality: CharacterPersonality(type: personality, description: "由描述自动生成"),
            skills: skills,
            generationPrompt: description
        )
    }

    // MARK: - Opponent & Quick Character Generation

    /// 生成 AI 对手角色
    static func generateOpponent(for player: Character) -> Character {
        let opponentNames = [
            "小火龙", "水灵灵", "风暴鸟", "岩石兽",
            "铁甲虫", "幽灵猫", "光明兔", "雷霆鹰",
            "暗影狼", "冰霜熊"
        ]
        let name = opponentNames.randomElement() ?? "神秘对手"
        let element = pickOpponentElement(against: player.element)
        let bodyTypes: [CharacterAppearance.BodyType] = [.robot, .monster, .animal, .humanoid]
        let bodyType = bodyTypes.randomElement() ?? .monster
        let personalities: [CharacterPersonality.PersonalityType] = [.aggressive, .defensive, .balanced, .cunning, .wild]
        let personality = personalities.randomElement() ?? .balanced
        let stats = randomStats()
        let skills = generateSkills(element: element)

        let appearance = CharacterAppearance(
            bodyType: bodyType,
            primaryColor: elementColor(element),
            secondaryColor: "#333333",
            size: .medium,
            features: [],
            description: "AI 生成的对手角色"
        )

        return Character(
            name: name,
            ownerID: UUID(),
            appearance: appearance,
            stats: stats,
            element: element,
            personality: CharacterPersonality(type: personality, description: "AI 对手"),
            skills: skills,
            generationPrompt: "AI opponent"
        )
    }

    /// 快速对战的玩家角色
    static func generateQuickCharacter() -> Character {
        let quickNames = ["小勇士", "闪电侠", "火焰龙", "冰雪公主", "风之猎手", "大地守护者"]
        let name = quickNames.randomElement() ?? "小伙伴"
        let baseElements: [Element] = [.fire, .water, .wind, .earth]
        let element = baseElements.randomElement() ?? .fire
        let bodyTypes: [CharacterAppearance.BodyType] = [.robot, .monster, .animal, .humanoid, .dragon]
        let bodyType = bodyTypes.randomElement() ?? .monster
        let stats = randomStats()
        let skills = generateSkills(element: element)

        let appearance = CharacterAppearance(
            bodyType: bodyType,
            primaryColor: elementColor(element),
            secondaryColor: "#1C1C1C",
            size: .medium,
            features: [],
            description: "快速生成的角色"
        )

        return Character(
            name: name,
            ownerID: UUID(),
            appearance: appearance,
            stats: stats,
            element: element,
            personality: CharacterPersonality(type: .balanced, description: "快速对战角色"),
            skills: skills,
            generationPrompt: "quick battle"
        )
    }

    // MARK: - Detection Helpers

    static func detectElement(from text: String) -> Element {
        let t = text.lowercased()
        if t.contains("火") || t.contains("喷火") || t.contains("fire") || t.contains("烈焰") || t.contains("火焰") { return .fire }
        if t.contains("水") || t.contains("water") || t.contains("海") || t.contains("雨") { return .water }
        if t.contains("风") || t.contains("wind") || t.contains("飞") || t.contains("翅膀") { return .wind }
        if t.contains("土") || t.contains("earth") || t.contains("石") || t.contains("岩") { return .earth }
        return .normal
    }

    static func detectBodyType(from text: String) -> CharacterAppearance.BodyType {
        let t = text.lowercased()
        if t.contains("机器人") || t.contains("robot") || t.contains("机械") { return .robot }
        if t.contains("龙") || t.contains("恐龙") || t.contains("dragon") { return .dragon }
        if t.contains("动物") || t.contains("猫") || t.contains("狗") || t.contains("兔") || t.contains("鸟") { return .animal }
        if t.contains("人") || t.contains("战士") || t.contains("忍者") || t.contains("超人") { return .humanoid }
        return .monster
    }

    static func detectPersonality(from text: String) -> CharacterPersonality.PersonalityType {
        let t = text.lowercased()
        if t.contains("勇敢") || t.contains("强") || t.contains("猛") || t.contains("凶") { return .aggressive }
        if t.contains("防") || t.contains("盾") || t.contains("坚") || t.contains("厚") { return .defensive }
        if t.contains("聪明") || t.contains("狡猾") || t.contains("智") { return .cunning }
        if t.contains("随机") || t.contains("疯狂") || t.contains("乱") { return .wild }
        return .balanced
    }

    static func detectSize(from text: String) -> CharacterAppearance.Size {
        let t = text.lowercased()
        if t.contains("巨大") || t.contains("巨型") || t.contains("giant") { return .large }
        if t.contains("大") || t.contains("庞大") { return .large }
        if t.contains("小") || t.contains("迷你") || t.contains("tiny") { return .small }
        return .medium
    }

    // MARK: - Stat Generation

    static func generateStats(description: String = "") -> CharacterStats {
        let t = description.lowercased()
        var hpWeight = 3.5
        var atkWeight = 2.5
        var defWeight = 2.0
        var spdWeight = 2.0

        if t.contains("快") || t.contains("速") || t.contains("闪") { spdWeight += 1.5 }
        if t.contains("强") || t.contains("攻") || t.contains("力") { atkWeight += 1.5 }
        if t.contains("防") || t.contains("盾") || t.contains("坚") || t.contains("甲") { defWeight += 1.5 }
        if t.contains("血厚") || t.contains("耐") || t.contains("坦") { hpWeight += 1.5 }

        return distributeStats(
            totalPoints: 100,
            hpWeight: hpWeight,
            attackWeight: atkWeight,
            defenseWeight: defWeight,
            speedWeight: spdWeight
        )
    }

    static func randomStats(totalPoints: Int = 100) -> CharacterStats {
        distributeStats(
            totalPoints: totalPoints,
            hpWeight: Double.random(in: 2.5...4.5),
            attackWeight: Double.random(in: 1.5...3.5),
            defenseWeight: Double.random(in: 1.0...3.0),
            speedWeight: Double.random(in: 1.0...3.0)
        )
    }

    private static func distributeStats(
        totalPoints: Int,
        hpWeight: Double,
        attackWeight: Double,
        defenseWeight: Double,
        speedWeight: Double
    ) -> CharacterStats {
        let totalWeight = hpWeight + attackWeight + defenseWeight + speedWeight
        var hp = max(1, Int(Double(totalPoints) * hpWeight / totalWeight))
        var attack = max(1, Int(Double(totalPoints) * attackWeight / totalWeight))
        var defense = max(1, Int(Double(totalPoints) * defenseWeight / totalWeight))
        let speed = max(1, Int(Double(totalPoints) * speedWeight / totalWeight))

        // Adjust remainder to sum exactly to totalPoints
        let diff = totalPoints - (hp + attack + defense + speed)
        hp += diff

        return CharacterStats(hp: hp, attack: attack, defense: defense, speed: speed, totalPoints: totalPoints)
    }

    // MARK: - Skill Generation

    static func generateSkills(element: Element) -> [Skill] {
        var skills: [Skill] = []
        let pool = skillPool(for: element)

        // Always include a basic no-cooldown attack
        if let basic = pool.first(where: { $0.cooldown == 0 && $0.type == .attack }) {
            skills.append(basic)
        }

        // Add 1–3 more skills from the pool (avoid duplicates by name)
        let usedNames = Set(skills.map(\.name))
        let remaining = pool.filter { !usedNames.contains($0.name) }
        if !remaining.isEmpty {
            let extra = Array(remaining.shuffled().prefix(Int.random(in: 1...min(3, remaining.count))))
            skills.append(contentsOf: extra)
        }

        return Array(skills.prefix(Character.maxSkillCount))
    }

    private static func skillPool(for element: Element) -> [Skill] {
        switch element {
        case .fire:
            return [
                Skill(name: "火焰冲击", type: .attack, power: 40, element: .fire, cooldown: 0, accuracy: 95, description: "基础火焰攻击"),
                Skill(name: "烈焰风暴", type: .attack, power: 70, element: .fire, cooldown: 2, accuracy: 85,
                      effect: SkillEffect(type: .burn, duration: 2, damagePerTurn: 5), description: "强力火焰攻击，可能灼烧对手"),
                Skill(name: "火焰护盾", type: .defense, power: 0, element: .fire, cooldown: 3, accuracy: 100,
                      effect: SkillEffect(type: .defenseBoost, duration: 2, multiplier: 1.5), description: "火焰形成护盾，提升防御"),
                Skill(name: "烈焰治愈", type: .support, power: 0, element: .fire, cooldown: 4, accuracy: 100,
                      effect: SkillEffect(type: .heal, amount: 25), description: "火焰能量恢复生命"),
            ]
        case .water:
            return [
                Skill(name: "水流弹", type: .attack, power: 40, element: .water, cooldown: 0, accuracy: 95, description: "基础水系攻击"),
                Skill(name: "巨浪冲击", type: .attack, power: 65, element: .water, cooldown: 2, accuracy: 90, description: "强力水系攻击"),
                Skill(name: "水之壁", type: .defense, power: 0, element: .water, cooldown: 3, accuracy: 100,
                      effect: SkillEffect(type: .defenseBoost, duration: 2, multiplier: 1.5), description: "水墙保护，提升防御"),
                Skill(name: "生命之泉", type: .support, power: 0, element: .water, cooldown: 3, accuracy: 100,
                      effect: SkillEffect(type: .heal, amount: 30), description: "泉水恢复生命"),
            ]
        case .wind:
            return [
                Skill(name: "风刃", type: .attack, power: 40, element: .wind, cooldown: 0, accuracy: 95, description: "基础风系攻击"),
                Skill(name: "龙卷风", type: .attack, power: 70, element: .wind, cooldown: 2, accuracy: 80, description: "强力风系攻击"),
                Skill(name: "风之障壁", type: .defense, power: 0, element: .wind, cooldown: 3, accuracy: 100,
                      effect: SkillEffect(type: .defenseBoost, duration: 2, multiplier: 1.4), description: "风之壁保护"),
                Skill(name: "清风治愈", type: .support, power: 0, element: .wind, cooldown: 4, accuracy: 100,
                      effect: SkillEffect(type: .heal, amount: 20), description: "微风恢复生命"),
            ]
        case .earth:
            return [
                Skill(name: "岩石投掷", type: .attack, power: 45, element: .earth, cooldown: 0, accuracy: 90, description: "基础土系攻击"),
                Skill(name: "地裂", type: .attack, power: 65, element: .earth, cooldown: 2, accuracy: 85, description: "强力土系攻击"),
                Skill(name: "岩石护甲", type: .defense, power: 0, element: .earth, cooldown: 2, accuracy: 100,
                      effect: SkillEffect(type: .defenseBoost, duration: 3, multiplier: 1.6), description: "岩石护甲大幅提升防御"),
                Skill(name: "大地恢复", type: .support, power: 0, element: .earth, cooldown: 4, accuracy: 100,
                      effect: SkillEffect(type: .heal, amount: 25), description: "大地之力恢复生命"),
            ]
        default: // normal and others
            return [
                Skill(name: "猛击", type: .attack, power: 40, element: .normal, cooldown: 0, accuracy: 95, description: "基础攻击"),
                Skill(name: "猛扑", type: .attack, power: 60, element: .normal, cooldown: 1, accuracy: 90, description: "猛烈扑击"),
                Skill(name: "防御姿态", type: .defense, power: 0, element: .normal, cooldown: 3, accuracy: 100,
                      effect: SkillEffect(type: .defenseBoost, duration: 2, multiplier: 1.5), description: "防御姿态"),
                Skill(name: "恢复", type: .support, power: 0, element: .normal, cooldown: 4, accuracy: 100,
                      effect: SkillEffect(type: .heal, amount: 25), description: "恢复生命"),
            ]
        }
    }

    // MARK: - Helpers

    static func extractName(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let name = String(trimmed.prefix(8))
        return name.isEmpty ? "小伙伴" : name
    }

    private static func pickOpponentElement(against playerElement: Element) -> Element {
        let baseElements: [Element] = [.fire, .water, .wind, .earth, .normal]
        // 40% chance to counter player's element
        if Int.random(in: 0..<5) < 2 {
            if let counter = baseElements.first(where: { $0.strongAgainst == playerElement }) {
                return counter
            }
        }
        return baseElements.randomElement() ?? .normal
    }

    static func elementColor(_ element: Element) -> String {
        switch element {
        case .fire:      return "#FF4500"
        case .water:     return "#1E90FF"
        case .wind:      return "#2ECC71"
        case .earth:     return "#D2691E"
        case .lightning: return "#FFD700"
        case .ice:       return "#87CEEB"
        case .shadow:    return "#6A0DAD"
        case .light:     return "#FFFF00"
        case .normal:    return "#808080"
        }
    }
}
