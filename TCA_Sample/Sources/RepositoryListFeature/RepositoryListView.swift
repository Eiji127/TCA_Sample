//
//  RepositoryListView.swift
//
//
//  Created by 白数叡司 on 2024/04/20.
//

import ComposableArchitecture
import Entity
import SwiftUI

@Reducer
public struct RepositoryList {
    @ObservableState
    public struct State: Equatable {
        var repositories: [Repository] = []
        var isLoading: Bool = false
        
        public init() {}
    }
    
    public enum Action {
        /// 「画面の表示」を示すアクション
        case onAppear
        /// 「GitHub API Request の結果の取得」を示すアクション
        case searchRepositoriesResponse(Result<[Repository], Error>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(
                        .searchRepositoriesResponse(
                            Result {
                                let query = "composable"
                                let url = URL(string: "https://api.github.com/search/repositories?q=\(query)&sort=stars")!
                                var request = URLRequest(url: url)
                                if let token = Bundle.main.infoDictionary?["GitHubPersonalAccessToken"] as? String {
                                    request.setValue(
                                        "Bearer \(token)",
                                        forHTTPHeaderField: "Authorization"
                                    )
                                }
                                let (data, _) = try await URLSession.shared.data(for: request)
                                let repositories = try jsonDecoder.decode(GithubSearchResult.self, from: data).items
                                return repositories
                            }
                        )
                    )
                }
            case let .searchRepositoriesResponse(result):
                state.isLoading = false
                
                switch result {
                case let .success(response):
                    state.repositories = response
                    return .none
                case .failure:
                    // TODO: Handling Error
                    return .none
                }
            }
        }
    }
    
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

public struct RepositoryListView: View {
    
    public init() {}
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RepositoryListView()
}
