import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CharacterStore
    @State private var battlePlayer: Character?
    @State private var battleOpponent: Character?
    @State private var showBattle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    actionButtons

                    if !store.characters.isEmpty {
                        characterSection
                    }
                }
                .padding()
            }
            .navigationTitle("Little Buddy")
            .navigationDestination(isPresented: $showBattle) {
                if let player = battlePlayer, let opponent = battleOpponent {
                    BattleView(player: player, opponent: opponent)
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("小伙伴 🥳")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("用语言创造你的专属小怪兽，然后对战！")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink {
                CharacterCreationView()
            } label: {
                Label("创建新伙伴 ✨", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                startQuickBattle()
            } label: {
                Label("快速对战 ⚔️", systemImage: "bolt.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var characterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我的小伙伴")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(store.characters) { character in
                characterRow(character)
            }
        }
    }

    private func characterRow(_ character: Character) -> some View {
        HStack(spacing: 12) {
            CharacterAvatarView(character: character, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(character.element.emoji + " " + character.element.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                    Text("技能 ×\(character.skills.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("对战 ⚔️") {
                startBattle(with: character)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func startQuickBattle() {
        let player = AICharacterService.generateQuickCharacter()
        let opponent = AICharacterService.generateOpponent(for: player)
        battlePlayer = player
        battleOpponent = opponent
        showBattle = true
    }

    private func startBattle(with character: Character) {
        let opponent = AICharacterService.generateOpponent(for: character)
        battlePlayer = character
        battleOpponent = opponent
        showBattle = true
    }
}

#Preview {
    ContentView()
        .environmentObject(CharacterStore())
}
