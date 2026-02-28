import SwiftUI

/// 角色属性预览视图
struct CharacterPreviewView: View {
    let character: Character

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(character.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text(character.element.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }

            Divider()

            StatsRow(label: "HP", value: character.stats.hp)
            StatsRow(label: "攻击", value: character.stats.attack)
            StatsRow(label: "防御", value: character.stats.defense)
            StatsRow(label: "速度", value: character.stats.speed)

            if !character.skills.isEmpty {
                Text("技能")
                    .font(.headline)
                ForEach(character.skills) { skill in
                    Text("• \(skill.name) (\(skill.type.rawValue), 威力: \(skill.power))")
                        .font(.callout)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatsRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
