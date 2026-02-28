import SwiftUI
import SpriteKit

/// SwiftUI 包装器：将 SpriteKit 角色场景嵌入 SwiftUI
/// 可替代 CharacterAvatarView 在对战界面和预览中使用
struct CharacterSpriteView: View {
    let character: Character
    var size: CGFloat = 100

    var body: some View {
        SpriteView(scene: makeScene(), options: [.allowsTransparency])
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.15)
                    .stroke(borderColor.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: borderColor.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private func makeScene() -> CharacterSpriteScene {
        CharacterSpriteScene(
            character: character,
            size: CGSize(width: size * 2, height: size * 2) // 2x for retina
        )
    }

    private var borderColor: Color {
        switch character.element {
        case .fire:      return .red
        case .water:     return .blue
        case .wind:      return .green
        case .earth:     return .brown
        case .lightning: return .yellow
        case .ice:       return .cyan
        case .shadow:    return .purple
        case .light:     return .yellow
        case .normal:    return .gray
        }
    }
}
