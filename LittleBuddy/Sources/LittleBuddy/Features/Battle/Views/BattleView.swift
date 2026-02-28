import SwiftUI

struct BattleView: View {
    @StateObject private var viewModel: BattleViewModel
    @Environment(\.dismiss) private var dismiss

    init(player: Character, opponent: Character) {
        _viewModel = StateObject(wrappedValue: BattleViewModel(player: player, opponent: opponent))
    }

    var body: some View {
        VStack(spacing: 0) {
            // === 对手区域 ===
            CharacterBattleCard(
                character: viewModel.opponentCharacter,
                currentHP: viewModel.opponentHP,
                isPlayer: false
            )
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

            // === 战斗消息区 ===
            battleMessageArea
                .frame(maxHeight: 180)

            Spacer()

            // === 玩家区域 ===
            CharacterBattleCard(
                character: viewModel.playerCharacter,
                currentHP: viewModel.playerHP,
                isPlayer: true
            )
            .padding(.horizontal)

            // === 技能选择 / 状态提示 ===
            skillArea
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("第 \(viewModel.turnNumber) 回合")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if case .finished = viewModel.phase {
                    Button("返回") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.startBattle() }
        .overlay {
            if case .finished(let won) = viewModel.phase {
                BattleResultView(won: won) { dismiss() }
            }
        }
    }

    // MARK: - Sub-views

    private var battleMessageArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.battleLog) { entry in
                        Text(entry.message)
                            .font(entry.isSystemMessage ? .callout.bold() : .callout)
                            .foregroundStyle(logColor(for: entry))
                            .id(entry.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .onChange(of: viewModel.battleLog.count) { _, _ in
                if let last = viewModel.battleLog.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var skillArea: some View {
        Group {
            if case .playerTurn = viewModel.phase {
                VStack(spacing: 8) {
                    Text("选择技能：")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(viewModel.playerCharacter.skills) { skill in
                            SkillButton(
                                skill: skill,
                                isAvailable: viewModel.isSkillAvailable(skill),
                                cooldown: viewModel.cooldownRemaining(for: skill)
                            ) {
                                viewModel.playerSelectSkill(skill)
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if case .finished = viewModel.phase {
                EmptyView()
            } else {
                Text(viewModel.currentMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .frame(minHeight: 100)
    }

    private func logColor(for entry: BattleLogEntry) -> Color {
        if entry.isSystemMessage { return .primary }
        return entry.isPlayerAction ? .blue : .red
    }
}

// MARK: - Character Battle Card

private struct CharacterBattleCard: View {
    let character: Character
    let currentHP: Int
    let isPlayer: Bool

    var body: some View {
        HStack(spacing: 12) {
            CharacterSpriteView(character: character, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isPlayer ? "🙋" : "🤖")
                        .font(.caption)
                    Text(character.name)
                        .font(.headline)
                    Text(character.element.emoji)
                        .font(.caption)
                }

                HPBar(currentHP: currentHP, maxHP: character.stats.hp)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - HP Bar

private struct HPBar: View {
    let currentHP: Int
    let maxHP: Int

    private var fraction: Double {
        guard maxHP > 0 else { return 0 }
        return Double(max(0, currentHP)) / Double(maxHP)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * fraction)
                        .animation(.easeOut(duration: 0.5), value: fraction)
                }
            }
            .frame(height: 10)

            Text("HP \(max(0, currentHP)) / \(maxHP)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var barColor: Color {
        if fraction > 0.5 { return .green }
        if fraction > 0.2 { return .yellow }
        return .red
    }
}

// MARK: - Skill Button

private struct SkillButton: View {
    let skill: Skill
    let isAvailable: Bool
    let cooldown: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(skill.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if skill.power > 0 {
                        Text("威力 \(skill.power)")
                            .font(.caption2)
                    }
                    Text(skill.element.emoji)
                        .font(.caption)
                }

                if !isAvailable {
                    Text("冷却 \(cooldown) 回合")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isAvailable ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isAvailable ? Color.accentColor : Color.gray.opacity(0.3))
            )
        }
        .disabled(!isAvailable)
    }
}
