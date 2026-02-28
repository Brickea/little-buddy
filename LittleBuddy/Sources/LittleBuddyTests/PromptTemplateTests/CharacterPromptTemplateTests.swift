import XCTest
@testable import LittleBuddy

final class CharacterPromptTemplateTests: XCTestCase {

    func testSystemPromptIsNotEmpty() {
        XCTAssertFalse(CharacterPromptTemplate.systemPrompt.isEmpty)
    }

    func testSystemPromptContainsJSONFormatGuidance() {
        let prompt = CharacterPromptTemplate.systemPrompt
        XCTAssertTrue(prompt.contains("JSON"), "System prompt should mention JSON format")
        XCTAssertTrue(prompt.contains("hp"), "System prompt should mention hp attribute")
        XCTAssertTrue(prompt.contains("attack"), "System prompt should mention attack attribute")
        XCTAssertTrue(prompt.contains("defense"), "System prompt should mention defense attribute")
        XCTAssertTrue(prompt.contains("speed"), "System prompt should mention speed attribute")
    }

    func testSystemPromptContainsStatConstraint() {
        let prompt = CharacterPromptTemplate.systemPrompt
        XCTAssertTrue(prompt.contains("100"), "System prompt should mention 100 total stat points")
    }

    func testUserMessageContainsDescription() {
        let description = "一个会喷火的蓝色机器人"
        let message = CharacterPromptTemplate.userMessage(description: description)
        XCTAssertTrue(message.contains(description))
    }

    func testBuildMessagesHasTwoMessages() {
        let messages = CharacterPromptTemplate.buildMessages(description: "test")
        XCTAssertEqual(messages.count, 2)
    }

    func testBuildMessagesFirstIsSystem() {
        let messages = CharacterPromptTemplate.buildMessages(description: "test")
        XCTAssertEqual(messages[0].role, "system")
    }

    func testBuildMessagesSecondIsUser() {
        let messages = CharacterPromptTemplate.buildMessages(description: "test")
        XCTAssertEqual(messages[1].role, "user")
    }

    func testBuildMessagesUserContentContainsDescription() {
        let description = "超级快的闪电猫"
        let messages = CharacterPromptTemplate.buildMessages(description: description)
        XCTAssertTrue(messages[1].content.contains(description))
    }
}
