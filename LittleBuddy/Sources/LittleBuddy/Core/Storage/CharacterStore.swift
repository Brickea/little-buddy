import Foundation

/// 角色收藏夹 — Phase 0: 内存存储；Phase 1: SwiftData 持久化
@MainActor
final class CharacterStore: ObservableObject {
    @Published private(set) var characters: [Character] = []

    func add(_ character: Character) {
        characters.append(character)
    }

    func remove(id: UUID) {
        characters.removeAll { $0.id == id }
    }
}
