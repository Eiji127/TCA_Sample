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
