import Foundation

// MARK: - DSLValidationError

enum DSLValidationError: Error, LocalizedError, Equatable {
    case invalidStatSum(expected: Int, actual: Int)
    case tooManySkills(count: Int)
    case totalPointsOutOfRange(value: Int)
    case emptyName

    var errorDescription: String? {
        switch self {
        case let .invalidStatSum(expected, actual):
            return "属性点之和（\(actual)）必须等于 totalPoints（\(expected)）"
        case let .tooManySkills(count):
            return "技能数量（\(count)）超出上限（\(Character.maxSkillCount)）"
        case let .totalPointsOutOfRange(value):
            return "totalPoints（\(value)）必须在 \(Character.minTotalPoints)–\(Character.maxTotalPoints) 范围内"
        case .emptyName:
            return "角色名称不能为空"
        }
    }
}

// MARK: - DSLValidator

/// 校验 Character DSL 的完整性与合法性
enum DSLValidator {
    static func validate(_ character: Character) throws {
        guard !character.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DSLValidationError.emptyName
        }

        let total = character.stats.totalPoints
        guard (Character.minTotalPoints...Character.maxTotalPoints).contains(total) else {
            throw DSLValidationError.totalPointsOutOfRange(value: total)
        }

        guard character.stats.isValid else {
            throw DSLValidationError.invalidStatSum(
                expected: total,
                actual: character.stats.sum
            )
        }

        guard character.skills.count <= Character.maxSkillCount else {
            throw DSLValidationError.tooManySkills(count: character.skills.count)
        }
    }

    /// 返回校验结果（true = 合法），不抛出异常
    static func isValid(_ character: Character) -> Bool {
        (try? validate(character)) != nil
    }
}
