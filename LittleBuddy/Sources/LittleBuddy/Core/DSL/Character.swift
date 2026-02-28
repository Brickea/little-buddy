import Foundation

// MARK: - CharacterStats

/// 角色基础属性，总点数受 totalPoints 约束
struct CharacterStats: Codable, Equatable {
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
    let totalPoints: Int

    /// 初始化时校验属性点总和是否合法
    init(hp: Int, attack: Int, defense: Int, speed: Int, totalPoints: Int = 100) {
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.totalPoints = totalPoints
    }

    var sum: Int { hp + attack + defense + speed }
    var isValid: Bool { sum == totalPoints }
}

// MARK: - CharacterAppearance

struct CharacterAppearance: Codable, Equatable {
    enum BodyType: String, Codable {
        case robot     = "robot"
        case monster   = "monster"
        case animal    = "animal"
        case humanoid  = "humanoid"
        case dragon    = "dragon"       // 扩展包：奇幻生物
        case elemental = "elemental"    // 扩展包：元素
        case vehicle   = "vehicle"      // 扩展包：机械
    }

    enum Size: String, Codable {
        case small  = "small"
        case medium = "medium"
        case large  = "large"
        case giant  = "giant"   // 扩展包

        /// 尺寸对速度的倍率修正
        var speedMultiplier: Double {
            switch self {
            case .small:  return 1.1
            case .medium: return 1.0
            case .large:  return 0.9
            case .giant:  return 0.8
            }
        }
    }

    let bodyType: BodyType
    let primaryColor: String    // hex color, e.g. "#FF4500"
    let secondaryColor: String
    let size: Size
    let features: [String]      // e.g. ["iron_fist", "flame_emitter"]
    /// 自然语言描述原文（来自孩子的输入）
    let description: String
}

// MARK: - CharacterPersonality

struct CharacterPersonality: Codable, Equatable {
    enum PersonalityType: String, Codable {
        case aggressive = "aggressive"
        case defensive  = "defensive"
        case cunning    = "cunning"
        case balanced   = "balanced"
        case wild       = "wild"
    }

    let type: PersonalityType
    let description: String
}

// MARK: - Character

/// 游戏角色完整定义，对应 CHARACTER_DSL 规范 v1.0
struct Character: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let ownerID: UUID
    let createdAt: Date
    let dslVersion: String

    var appearance: CharacterAppearance
    var stats: CharacterStats
    var element: Element
    var personality: CharacterPersonality
    /// 最多 4 个技能
    var skills: [Skill]

    /// 用于生成角色的原始提示词（记录创作来源）
    let generationPrompt: String
    /// 已启用的扩展包 ID 列表
    let extensionPacks: [String]

    static let maxSkillCount = 4
    static let minTotalPoints = 100
    static let maxTotalPoints = 200

    init(
        id: UUID = UUID(),
        name: String,
        ownerID: UUID,
        createdAt: Date = Date(),
        dslVersion: String = "1.0",
        appearance: CharacterAppearance,
        stats: CharacterStats,
        element: Element,
        personality: CharacterPersonality,
        skills: [Skill],
        generationPrompt: String,
        extensionPacks: [String] = ["base"]
    ) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.dslVersion = dslVersion
        self.appearance = appearance
        self.stats = stats
        self.element = element
        self.personality = personality
        self.skills = Array(skills.prefix(Character.maxSkillCount))
        self.generationPrompt = generationPrompt
        self.extensionPacks = extensionPacks
    }
}
