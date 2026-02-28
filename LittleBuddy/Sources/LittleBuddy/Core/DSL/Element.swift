import Foundation

// MARK: - Element

/// 角色或技能的元素属性，决定克制关系
enum Element: String, Codable, CaseIterable {
    case fire       = "fire"
    case water      = "water"
    case wind       = "wind"
    case earth      = "earth"
    case lightning  = "lightning"   // 扩展包：自然之力
    case ice        = "ice"         // 扩展包：自然之力
    case shadow     = "shadow"      // 扩展包：光暗
    case light      = "light"       // 扩展包：光暗
    case normal     = "normal"

    /// 返回该元素克制的元素（攻击时伤害 x1.5）
    var strongAgainst: Element? {
        switch self {
        case .fire:      return .wind
        case .water:     return .fire
        case .wind:      return .earth
        case .earth:     return .water
        case .lightning: return .water
        case .ice:       return .wind
        case .shadow:    return .light
        case .light:     return .shadow
        case .normal:    return nil
        }
    }

    /// 是否属于基础包，不属于则需要扩展包
    var isBase: Bool {
        switch self {
        case .fire, .water, .wind, .earth, .normal: return true
        default: return false
        }
    }
}
