import Foundation

/// API 配置管理
/// 支持多种 API Key 注入方式：环境变量、运行时设置
enum APIConfig {
    /// ChatAnywhere API 基础 URL（OpenAI 兼容接口）
    static let chatAnywhereBaseURL = "https://api.chatanywhere.tech"

    /// Chat Completions 端点
    static var chatCompletionsURL: URL {
        URL(string: "\(chatAnywhereBaseURL)/v1/chat/completions")!
    }

    /// 默认模型
    static let defaultModel = "gpt-4o-mini"

    /// 运行时 API Key（可由 App 启动时注入）
    static var apiKey: String? {
        // 优先使用运行时设置的 key
        if let runtimeKey = _runtimeAPIKey, !runtimeKey.isEmpty {
            return runtimeKey
        }
        // 其次从环境变量读取（CI / 开发调试时使用）
        if let envKey = ProcessInfo.processInfo.environment["CHAT_ANYWHERE_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        return nil
    }

    /// 是否已配置 API Key
    static var isConfigured: Bool {
        apiKey != nil
    }

    // MARK: - Runtime Key Injection

    private static var _runtimeAPIKey: String?

    /// 在运行时设置 API Key（例如从 Keychain 或配置文件读取后注入）
    static func setAPIKey(_ key: String) {
        _runtimeAPIKey = key
    }
}
