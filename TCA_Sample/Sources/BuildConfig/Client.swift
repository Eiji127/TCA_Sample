//
//  Client.swift
//  
//
//  Created by 白数叡司 on 2024/06/09.
//

import Dependencies
import Foundation

public struct BuildConfigurationClient {
    public var fetchGithubPersonalAccessToken: @Sendable () async throws -> String
}

extension BuildConfigurationClient: DependencyKey {
    public static var liveValue: BuildConfigurationClient = Self(
        fetchGithubPersonalAccessToken: {
            guard let token = Bundle.main.infoDictionary?["GithubPersonalAccessToken"] as? String else {
                return ""
            }
            return token
        }
    )
}

extension DependencyValues {
    public var buildConfigurationClient: BuildConfigurationClient {
        get { self[BuildConfigurationClient.self] }
        set { self[BuildConfigurationClient.self] = newValue }
    }
}
