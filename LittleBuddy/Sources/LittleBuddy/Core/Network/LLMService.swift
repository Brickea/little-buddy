import Foundation

// MARK: - LLM Request/Response Models

/// OpenAI 兼容的 Chat Completion 请求
struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let max_tokens: Int

    init(
        model: String = APIConfig.defaultModel,
        messages: [ChatMessage],
        temperature: Double = 0.7,
        maxTokens: Int = 1500
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.max_tokens = maxTokens
    }
}

struct ChatMessage: Codable {
    let role: String   // "system" | "user" | "assistant"
    let content: String
}

/// OpenAI 兼容的 Chat Completion 响应
struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ResponseMessage
    }

    struct ResponseMessage: Decodable {
        let content: String?
    }
}

// MARK: - LLM Errors

enum LLMServiceError: Error, LocalizedError {
    case apiKeyNotConfigured
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int, body: String)
    case emptyResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "API Key 未配置"
        case .invalidURL:
            return "无效的 API URL"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .httpError(let code, let body):
            return "HTTP 错误 \(code): \(body)"
        case .emptyResponse:
            return "AI 返回了空响应"
        case .decodingError(let error):
            return "响应解析失败: \(error.localizedDescription)"
        }
    }
}

// MARK: - LLMService

/// 调用 ChatAnywhere (OpenAI 兼容) LLM API
struct LLMService {
    private let session: URLSession
    private let baseURL: String

    init(
        session: URLSession = .shared,
        baseURL: String = APIConfig.chatAnywhereBaseURL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    /// 发送 Chat Completion 请求并返回助手消息文本
    func chatCompletion(messages: [ChatMessage], temperature: Double = 0.7) async throws -> String {
        guard let apiKey = APIConfig.apiKey else {
            throw LLMServiceError.apiKeyNotConfigured
        }

        guard let url = URL(string: "\(baseURL)/v1/chat/completions") else {
            throw LLMServiceError.invalidURL
        }

        let requestBody = ChatCompletionRequest(
            messages: messages,
            temperature: temperature
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw LLMServiceError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw LLMServiceError.httpError(statusCode: httpResponse.statusCode, body: body)
        }

        let decoded: ChatCompletionResponse
        do {
            decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        } catch {
            throw LLMServiceError.decodingError(error)
        }

        guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
            throw LLMServiceError.emptyResponse
        }

        return content
    }
}
