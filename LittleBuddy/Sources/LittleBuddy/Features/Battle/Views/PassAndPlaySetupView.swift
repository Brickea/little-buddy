import SwiftUI

// MARK: - PassAndPlayPhase

enum PassAndPlayPhase {
    case player1Select
    case passToPlayer2
    case player2Select
    case readyToBattle
}

// MARK: - PassAndPlaySetupView

/// Pass-and-Play 设置视图：两位玩家轮流在同一设备上选择角色
struct PassAndPlaySetupView: View {
    @EnvironmentObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var phase: PassAndPlayPhase = .player1Select
    @State private var player1Character: Character?
    @State private var player2Character: Character?
    @State private var showBattle = false

    var body: some View {
        VStack(spacing: 0) {
            switch phase {
            case .player1Select:
                playerSelectionView(playerNumber: 1)
            case .passToPlayer2:
                passDeviceView
            case .player2Select:
                playerSelectionView(playerNumber: 2)
            case .readyToBattle:
                readyView
            }
        }
        .navigationTitle("本地双人对战")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showBattle) {
            if let p1 = player1Character, let p2 = player2Character {
                PassAndPlayBattleView(player1: p1, player2: p2)
            }
        }
    }

    // MARK: - Player Selection

    private func playerSelectionView(playerNumber: Int) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("玩家 \(playerNumber)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(playerNumber == 1 ? .blue : .red)

                Text("选择你的小伙伴！")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                // 快速生成选项
                Button {
                    let character = AICharacterService.generateQuickCharacter()
                    selectCharacter(character, forPlayer: playerNumber)
                } label: {
                    Label("随机生成角色 🎲", systemImage: "dice.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(playerNumber == 1 ? .blue : .red)
                .controlSize(.large)

                // 从已保存角色中选择
                if !store.characters.isEmpty {
                    Divider()

                    Text("或从已有角色中选择：")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(store.characters) { character in
                        Button {
                            selectCharacter(character, forPlayer: playerNumber)
                        } label: {
                            HStack(spacing: 12) {
                                CharacterAvatarView(character: character, size: 50)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(character.name)
                                        .font(.headline)
                                    HStack(spacing: 6) {
                                        Text(character.element.emoji + " " + character.element.displayName)
                                            .font(.caption)
                                        Text("技能 ×\(character.skills.count)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Pass Device Screen

    private var passDeviceView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("📱")
                .font(.system(size: 80))

            Text("把设备交给玩家 2！")
                .font(.title.bold())

            Text("玩家 1 已选好角色，请将设备递给第二位玩家。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("玩家 2 准备好了 ✋") {
                withAnimation {
                    phase = .player2Select
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }

    // MARK: - Ready View

    private var readyView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("⚔️ 准备开战！")
                .font(.largeTitle.bold())

            if let p1 = player1Character, let p2 = player2Character {
                HStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("玩家 1").font(.caption.bold()).foregroundStyle(.blue)
                        CharacterAvatarView(character: p1, size: 60)
                        Text(p1.name).font(.subheadline.bold())
                        Text(p1.element.emoji + " " + p1.element.displayName).font(.caption)
                    }

                    Text("VS")
                        .font(.title.bold())
                        .foregroundStyle(.orange)

                    VStack(spacing: 8) {
                        Text("玩家 2").font(.caption.bold()).foregroundStyle(.red)
                        CharacterAvatarView(character: p2, size: 60)
                        Text(p2.name).font(.subheadline.bold())
                        Text(p2.element.emoji + " " + p2.element.displayName).font(.caption)
                    }
                }
            }

            Button("开始对战！ 🔥") {
                showBattle = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }

    // MARK: - Actions

    private func selectCharacter(_ character: Character, forPlayer player: Int) {
        withAnimation {
            if player == 1 {
                player1Character = character
                phase = .passToPlayer2
            } else {
                player2Character = character
                phase = .readyToBattle
            }
        }
    }
}
