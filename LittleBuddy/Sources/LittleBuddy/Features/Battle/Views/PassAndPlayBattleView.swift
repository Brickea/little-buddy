import SwiftUI

/// Pass-and-Play 对战视图：两位玩家在同一设备上轮流操作
struct PassAndPlayBattleView: View {
    @StateObject private var viewModel: PassAndPlayBattleViewModel
    @Environment(\.dismiss) private var dismiss

    init(player1: Character, player2: Character) {
        _viewModel = StateObject(wrappedValue: PassAndPlayBattleViewModel(player1: player1, player2: player2))
    }

    var body: some View {
        ZStack {
            battleContent

            // 传屏提示覆盖
            if case .passToPlayer(let player) = viewModel.phase {
                passDeviceOverlay(player: player)
            }

            // 结果覆盖
            if case .finished(let winnerPlayer) = viewModel.phase {
                passAndPlayResultOverlay(winnerPlayer: winnerPlayer)
            }
        }
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
    }

    // MARK: - Battle Content

    private var battleContent: some View {
        VStack(spacing: 0) {
            // 玩家 2 区域（顶部）
            PassAndPlayCharacterCard(
                character: viewModel.player2Character,
                currentHP: viewModel.player2HP,
                playerLabel: "玩家 2"
            )
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

            // 战斗日志
            battleMessageArea
                .frame(maxHeight: 180)

            Spacer()

            // 玩家 1 区域（底部）
            PassAndPlayCharacterCard(
                character: viewModel.player1Character,
                currentHP: viewModel.player1HP,
                playerLabel: "玩家 1"
            )
            .padding(.horizontal)

            // 技能选择区域
            skillArea
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Battle Message Area

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

    // MARK: - Skill Area

    private var skillArea: some View {
        Group {
            if case .playerTurn(let player) = viewModel.phase {
                let character = player == 1 ? viewModel.player1Character : viewModel.player2Character
                VStack(spacing: 8) {
                    Text("玩家 \(player) 选择技能：")
                        .font(.subheadline.bold())
                        .foregroundStyle(player == 1 ? .blue : .red)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(character.skills) { skill in
                            PassAndPlaySkillButton(
                                skill: skill,
                                isAvailable: viewModel.isSkillAvailable(skill, forPlayer: player),
                                cooldown: viewModel.cooldownRemaining(for: skill, player: player),
                                playerColor: player == 1 ? .blue : .red
                            ) {
                                viewModel.selectSkill(skill, byPlayer: player)
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

    // MARK: - Pass Device Overlay

    private func passDeviceOverlay(player: Int) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("📱")
                    .font(.system(size: 60))

                Text("请将设备交给玩家 \(player)")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                let character = player == 1 ? viewModel.player1Character : viewModel.player2Character
                VStack(spacing: 8) {
                    CharacterAvatarView(character: character, size: 50)
                    Text(character.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Button("玩家 \(player) 准备好了 ✋") {
                    withAnimation {
                        viewModel.playerReady()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(player == 1 ? .blue : .red)
                .controlSize(.large)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 20)
            .padding(24)
        }
    }

    // MARK: - Result Overlay

    private func passAndPlayResultOverlay(winnerPlayer: Int) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))

                Text("玩家 \(winnerPlayer) 赢了！")
                    .font(.largeTitle.bold())
                    .foregroundStyle(winnerPlayer == 1 ? .blue : .red)

                let winnerCharacter = winnerPlayer == 1 ? viewModel.player1Character : viewModel.player2Character
                Text("恭喜「\(winnerCharacter.name)」取得胜利！🏆")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Button("返回首页 🏠") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(winnerPlayer == 1 ? .blue : .red)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 20)
            .padding(24)
        }
    }

    // MARK: - Helpers

    private func logColor(for entry: BattleLogEntry) -> Color {
        if entry.isSystemMessage { return .primary }
        return entry.isPlayerAction ? .blue : .red
    }
}

// MARK: - Character Card

private struct PassAndPlayCharacterCard: View {
    let character: Character
    let currentHP: Int
    let playerLabel: String

    var body: some View {
        HStack(spacing: 12) {
            CharacterAvatarView(character: character, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(playerLabel)
                        .font(.caption.bold())
                        .foregroundStyle(playerLabel == "玩家 1" ? .blue : .red)
                    Text(character.name)
                        .font(.headline)
                    Text(character.element.emoji)
                        .font(.caption)
                }

                PassAndPlayHPBar(currentHP: currentHP, maxHP: character.stats.hp)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - HP Bar

private struct PassAndPlayHPBar: View {
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

private struct PassAndPlaySkillButton: View {
    let skill: Skill
    let isAvailable: Bool
    let cooldown: Int
    let playerColor: Color
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
            .background(isAvailable ? playerColor.opacity(0.15) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isAvailable ? playerColor : Color.gray.opacity(0.3))
            )
        }
        .disabled(!isAvailable)
    }
}
