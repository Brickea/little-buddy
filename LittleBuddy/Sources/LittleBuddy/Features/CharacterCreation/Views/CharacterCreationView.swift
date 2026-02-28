import SwiftUI

/// 角色创建引导视图（Phase 0 占位，将在 Phase 1 完善）
struct CharacterCreationView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("告诉我你的小伙伴是什么样的？")
                .font(.title2)
                .multilineTextAlignment(.center)

            TextEditor(text: $viewModel.userInput)
                .frame(minHeight: 120)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.4))
                )

            Button("生成角色 ✨") {
                Task { await viewModel.generateCharacter() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userInput.isEmpty || viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView("AI 正在构建你的小伙伴…")
            }

            if let character = viewModel.generatedCharacter {
                CharacterPreviewView(character: character)
            }
        }
        .padding()
        .navigationTitle("创建新伙伴")
    }
}
