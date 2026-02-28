import SwiftUI

/// 角色创建引导视图
struct CharacterCreationView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()
    @EnvironmentObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("告诉我你的小伙伴是什么样的？🤔")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text("例如：一个会喷火的蓝色机器人，拳头像铁锤！")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                TextEditor(text: $viewModel.userInput)
                    .frame(minHeight: 100)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.4))
                    )

                Button("生成角色 ✨") {
                    Task { await viewModel.generateCharacter() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView("AI 正在构建你的小伙伴… 🧠")
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.callout)
                }

                if let character = viewModel.generatedCharacter {
                    CharacterPreviewView(character: character)

                    if viewModel.isSaved {
                        Label("已保存！", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.headline)
                    } else {
                        Button("保存小伙伴 💾") {
                            viewModel.save(to: store)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                    }

                    Button("返回首页 🏠") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("创建新伙伴")
    }
}
