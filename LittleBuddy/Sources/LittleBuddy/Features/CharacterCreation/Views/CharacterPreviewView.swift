import SwiftUI

/// 角色属性预览视图
struct CharacterPreviewView: View {
    let character: Character

    var body: some View {
        VStack(spacing: 16) {
            CharacterAvatarView(character: character, size: 80)

            HStack {
                Text(character.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(character.element.emoji + " " + character.element.displayName)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }

            Divider()

            VStack(spacing: 8) {
                StatsBar(label: "❤️ HP", value: character.stats.hp, maxValue: 50, color: .red)
                StatsBar(label: "⚔️ 攻击", value: character.stats.attack, maxValue: 40, color: .orange)
                StatsBar(label: "🛡️ 防御", value: character.stats.defense, maxValue: 40, color: .blue)
                StatsBar(label: "💨 速度", value: character.stats.speed, maxValue: 40, color: .green)
            }

            if !character.skills.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("技能")
                        .font(.headline)
                    ForEach(character.skills) { skill in
                        HStack {
                            Text(skill.element.emoji)
                            Text(skill.name)
                                .font(.subheadline.bold())
                            Spacer()
                            if skill.power > 0 {
                                Text("威力 \(skill.power)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(skill.type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stats Bar

private struct StatsBar: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.subheadline)
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * min(1.0, Double(value) / Double(maxValue)))
                }
            }
            .frame(height: 8)

            Text("\(value)")
                .font(.subheadline.bold())
                .frame(width: 30, alignment: .trailing)
        }
    }
}
