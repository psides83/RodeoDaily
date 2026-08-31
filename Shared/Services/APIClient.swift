//
//  APIClient.swift
//  RodeoDaily
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum APIClientError: LocalizedError {
    case invalidResponse
    case invalidStatusCode(Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .invalidStatusCode(let statusCode, let body):
            return "Request failed (\(statusCode)): \(body)"
        }
    }
}

enum APIClient {
    static func data(
        for request: URLRequest,
        validStatusCodes: Range<Int> = 200..<300
    ) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data, validStatusCodes: validStatusCodes)
        return data
    }

    static func data(
        from url: URL,
        validStatusCodes: Range<Int> = 200..<300
    ) async throws -> Data {
        try await data(for: URLRequest(url: url), validStatusCodes: validStatusCodes)
    }

    static func fetch<T: Decodable>(
        _ type: T.Type = T.self,
        for request: URLRequest,
        decoder: JSONDecoder = JSONDecoder(),
        validStatusCodes: Range<Int> = 200..<300
    ) async throws -> T {
        let data = try await data(for: request, validStatusCodes: validStatusCodes)
        return try decoder.decode(type, from: data)
    }

    static func fetch<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        decoder: JSONDecoder = JSONDecoder(),
        validStatusCodes: Range<Int> = 200..<300
    ) async throws -> T {
        try await fetch(type, for: URLRequest(url: url), decoder: decoder, validStatusCodes: validStatusCodes)
    }

    private static func validate(
        response: URLResponse,
        data: Data,
        validStatusCodes: Range<Int>
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard validStatusCodes.contains(httpResponse.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<empty>"
            throw APIClientError.invalidStatusCode(httpResponse.statusCode, body: bodyText)
        }
    }
}
