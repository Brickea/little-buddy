import XCTest
@testable import LittleBuddy

@MainActor
final class CharacterStoreTests: XCTestCase {

    func testStoreStartsEmpty() {
        let store = CharacterStore()
        XCTAssertTrue(store.characters.isEmpty)
    }

    func testAddCharacter() {
        let store = CharacterStore()
        let character = makeTestCharacter(name: "测试角色")
        store.add(character)
        XCTAssertEqual(store.characters.count, 1)
        XCTAssertEqual(store.characters.first?.name, "测试角色")
    }

    func testAddMultipleCharacters() {
        let store = CharacterStore()
        store.add(makeTestCharacter(name: "角色一"))
        store.add(makeTestCharacter(name: "角色二"))
        store.add(makeTestCharacter(name: "角色三"))
        XCTAssertEqual(store.characters.count, 3)
    }

    func testRemoveCharacterByID() {
        let store = CharacterStore()
        let character = makeTestCharacter(name: "将被删除")
        store.add(character)
        XCTAssertEqual(store.characters.count, 1)

        store.remove(id: character.id)
        XCTAssertTrue(store.characters.isEmpty)
    }

    func testRemoveOnlyTargetCharacter() {
        let store = CharacterStore()
        let c1 = makeTestCharacter(name: "保留")
        let c2 = makeTestCharacter(name: "删除")
        store.add(c1)
        store.add(c2)

        store.remove(id: c2.id)
        XCTAssertEqual(store.characters.count, 1)
        XCTAssertEqual(store.characters.first?.id, c1.id)
    }

    func testRemoveNonexistentIDDoesNothing() {
        let store = CharacterStore()
        let character = makeTestCharacter(name: "测试")
        store.add(character)

        store.remove(id: UUID()) // non-existent ID
        XCTAssertEqual(store.characters.count, 1)
    }

    // MARK: - Helpers

    private func makeTestCharacter(name: String) -> Character {
        Character(
            name: name,
            ownerID: UUID(),
            appearance: CharacterAppearance(
                bodyType: .monster,
                primaryColor: "#FF0000",
                secondaryColor: "#000000",
                size: .medium,
                features: [],
                description: "test"
            ),
            stats: CharacterStats(hp: 40, attack: 25, defense: 20, speed: 15),
            element: .fire,
            personality: CharacterPersonality(type: .balanced, description: ""),
            skills: [],
            generationPrompt: "test"
        )
    }
}
