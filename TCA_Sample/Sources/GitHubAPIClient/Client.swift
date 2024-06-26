//
//  Client.swift
//
//
//  Created by 白数叡司 on 2024/04/27.
//
import BuildConfig
import Dependencies
import Entity
import Foundation
import XCTestDynamicOverlay

public struct GithubAPIClient {
    @Dependency(\.buildConfigurationClient) var buildConfigurationClient
    public var searchRepositories: @Sendable (_ query: String) async throws -> [Repository]
}

extension GithubAPIClient: DependencyKey {
    public static var liveValue: GithubAPIClient = Self(
        searchRepositories: { query in
            let url = URL(
                string: "https://api.github.com/search/repositories?q=\(query)&sort=stars"
            )!
            var request = URLRequest(url: url)
            let token = self.buildConfigurationClient.fetchGithubPersonalAccessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            let repositories = try jsonDecoder.decode(
                GithubSearchResult.self,
                from: data
            ).items
            return repositories
        }
    )
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

extension GithubAPIClient: TestDependencyKey {
    public static let previewValue = Self(
        searchRepositories: { _ in [] }
    )
    
    public static let testValue = Self(
        searchRepositories: unimplemented("\(Self.self).searchRepositories")
    )
}

extension DependencyValues {
    public var gitHubAPIClient: GithubAPIClient {
        get { self[GithubAPIClient.self] }
        set { self[GithubAPIClient.self] = newValue }
    }
}
