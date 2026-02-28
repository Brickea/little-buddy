import SwiftUI

/// 角色形象视图 — Phase 0 使用 Emoji + 元素颜色
struct CharacterAvatarView: View {
    let character: Character
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill(elementGradient)
                .frame(width: size, height: size)
                .shadow(color: shadowColor.opacity(0.4), radius: 4, x: 0, y: 2)

            Text(bodyEmoji)
                .font(.system(size: size * 0.45))
        }
    }

    private var bodyEmoji: String {
        switch character.appearance.bodyType {
        case .robot:     return "🤖"
        case .monster:   return "👾"
        case .animal:    return "🐱"
        case .humanoid:  return "🦸"
        case .dragon:    return "🐉"
        case .elemental: return "✨"
        case .vehicle:   return "🚗"
        }
    }

    private var elementGradient: LinearGradient {
        LinearGradient(
            colors: elementColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var elementColors: [Color] {
        switch character.element {
        case .fire:      return [.red, .orange]
        case .water:     return [.blue, .cyan]
        case .wind:      return [.green, .mint]
        case .earth:     return [Color.brown, .orange]
        case .lightning: return [.yellow, .orange]
        case .ice:       return [.cyan, .white]
        case .shadow:    return [.purple, .indigo]
        case .light:     return [.yellow, .white]
        case .normal:    return [.gray, Color(.systemGray4)]
        }
    }

    private var shadowColor: Color {
        elementColors.first ?? .gray
    }
}
