import Foundation

@MainActor
final class CharacterCreationViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var generatedCharacter: Character?
    @Published var errorMessage: String?

    private let aiService = AICharacterService()

    func generateCharacter() async {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            generatedCharacter = try await aiService.generate(from: userInput)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
