import Foundation

// MARK: - API Error

enum APIError: Error, LocalizedError {
    /// Server returned 401 Unauthorized.
    case unauthorized
    /// Server returned 404 Not Found.
    case notFound
    /// Server returned a 5xx status code.
    case serverError(Int)
    /// A URLSession-level network failure occurred.
    case networkError(Error)
    /// JSON decoding failed.
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to read server response: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Client

actor APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL = URL(string: "https://api.preflight.valderis.com")!) {
        self.baseURL = baseURL
        self.session = URLSession.shared

        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Public Interface

    /// Perform a request and decode the JSON response body into `T`.
    func fetch<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: (any Encodable)? = nil
    ) async throws -> T {
        let data = try await performRequest(path: path, method: method, body: body)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    /// Perform a request without decoding the response body (fire-and-forget).
    func send(
        _ path: String,
        method: String,
        body: (any Encodable)? = nil
    ) async throws {
        _ = try await performRequest(path: path, method: method, body: body)
    }

    // MARK: - Private

    /// Build and execute the URLRequest with retry logic.
    private func performRequest(
        path: String,
        method: String,
        body: (any Encodable)?
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach bearer token if available
        if let token = KeychainHelper.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode request body
        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Retry configuration: POST gets 3 attempts, everything else gets 1 retry (2 attempts total).
        // Match the TS behavior: maxRetries is the total number of attempts.
        let maxAttempts = method.uppercased() == "POST" ? 3 : 2

        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.networkError(
                        URLError(.badServerResponse)
                    )
                }

                let statusCode = httpResponse.statusCode

                // Success range
                if (200...299).contains(statusCode) {
                    return data
                }

                // Determine if this status code is retryable (5xx or 429)
                let isRetryable = statusCode >= 500 || statusCode == 429

                if attempt < maxAttempts && isRetryable {
                    // Exponential backoff: 1s, 2s, 3s (matching TS: 1000 * attempt)
                    try await Task.sleep(for: .seconds(attempt))
                    continue
                }

                // Not retryable or out of retries — throw the appropriate error
                throw apiError(for: statusCode)

            } catch let error as APIError {
                // Already a typed APIError — don't wrap it
                throw error
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // Network-level error (URLSession failure) — retry if attempts remain
                lastError = error
                if attempt < maxAttempts {
                    try await Task.sleep(for: .seconds(attempt))
                    continue
                }
            }
        }

        throw APIError.networkError(lastError ?? URLError(.unknown))
    }

    /// Map an HTTP status code to the appropriate APIError case.
    private func apiError(for statusCode: Int) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 500...599:
            return .serverError(statusCode)
        default:
            return .serverError(statusCode)
        }
    }
}

// MARK: - AnyEncodable

/// Type-erasing wrapper so we can encode `any Encodable` through JSONEncoder.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        self._encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
