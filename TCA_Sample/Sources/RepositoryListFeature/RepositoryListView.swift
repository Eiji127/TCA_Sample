//
//  RepositoryListView.swift
//
//
//  Created by 白数叡司 on 2024/04/20.
//
import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import Foundation
import GithubAPIClient
import IdentifiedCollections
import RepositoryDetailFeature
import SwiftUI
import SwiftUINavigationCore

// MARK: - Reducer
@Reducer
public struct RepositoryList {
    @ObservableState
    public struct State: Equatable {
        var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
        var isLoading: Bool = false
        var query: String = ""
        @Presents var destination: Destination.State?
        var path = StackState<Path.State>()
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        /// 「画面の表示」を示すアクション
        case onAppear
        /// 「GitHub API Request の結果の取得」を示すアクション
        case searchRepositoriesResponse(Result<[Repository], Error>)
        case repositoryRows(IdentifiedActionOf<RepositoryRow>)
        case queryChangeDebounced
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    public init() {}
    
    private enum CancelId {
        case response
    }
    
    @Dependency(\.gitHubAPIClient) var githubAPIClient
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return searchRepositories(by: "composable")
            case let .searchRepositoriesResponse(result):
                state.isLoading = false
                
                switch result {
                case let .success(response):
                    state.repositoryRows = .init(
                        uniqueElements: response.map {
                            .init(repository: $0)
                        }
                    )
                    return .none
                case .failure:
                    state.destination = .alert(.networkError)
                    return .none
                }
            case let .repositoryRows(.element(id, .delegate(.rowTapped))):
                guard let repository = state.repositoryRows[id: id]?.repository else {
                    return .none
                }
                
                state.path.append(
                    .repositoryDetail(
                        .init(repository: repository)
                    )
                )
                return .none
            case .repositoryRows:
                return .none
            case .binding(\.query):
                return .run { send in
                    await send(.queryChangeDebounced)
                }
                .debounce(
                    id: CancelId.response,
                    for: .seconds(0.3),
                    scheduler: mainQueue
                )
            case .queryChangeDebounced:
                guard !state.query.isEmpty else {
                    return .none
                }
                state.isLoading = true
                return searchRepositories(by: state.query)
            case .binding:
                return .none
            case .destination:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.repositoryRows, action: \.repositoryRows) {
            RepositoryRow()
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
    
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func searchRepositories(by query: String) -> Effect<Action> {
        .run { send in
            await send(
                .searchRepositoriesResponse(
                    Result {
                        try await githubAPIClient.searchRepositories(query)
                    }
                )
            )
        }
    }
}

extension AlertState where Action == RepositoryList.Destination.Alert {
    static let networkError = Self {
        TextState("Network Error")
    } message: {
        TextState("Failed to fetch data.")
    }
}

extension RepositoryList {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        
        public enum Alert: Equatable {}
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case repositoryDetail(RepositoryDetail)
    }
}

// MARK: - View
public struct RepositoryListView: View {
    @Bindable var store: StoreOf<RepositoryList>
    
    public init(store: StoreOf<RepositoryList>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(
                state: \.path,
                action: \.path
            )
        ) {
            Group {
                if store.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(
                            store.scope(
                                state: \.repositoryRows,
                                action: \.repositoryRows
                            ),
                            content: RepositoryRowView.init(store:)
                        )
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationTitle("Repositories")
            .searchable(
                text: $store.query,
                placement: .navigationBarDrawer,
                prompt: "Input query"
            )
            .alert(
                $store.scope(
                    state: \.destination?.alert,
                    action: \.destination.alert
                )
            )
        } destination: { store in
            switch store.case {
            case let .repositoryDetail(store):
                RepositoryDetailView(store: store)
            }
        }
    }
}

#Preview("API Succeded") {
    RepositoryListView(
        store: .init(
            initialState: RepositoryList.State()
        ) {
            RepositoryList()._printChanges()
        } withDependencies: {
            $0.gitHubAPIClient.searchRepositories = { _ in
                try await Task.sleep(for: .seconds(0.3))
                return (1...20).map { .mock(id: $0) }
            }
        }
    )
}

#Preview("API Failed") {
    enum PreviewError: Error {
        case fetchFailed
    }
    return RepositoryListView(
        store: .init(
            initialState: RepositoryList.State()
        ) {
            RepositoryList()
        } withDependencies: {
            $0.gitHubAPIClient.searchRepositories = { _ in
                throw PreviewError.fetchFailed
            }
        }
    )
}
