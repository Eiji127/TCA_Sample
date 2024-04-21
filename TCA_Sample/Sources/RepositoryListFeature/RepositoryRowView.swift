//
//  RepositoryRowView.swift
//
//
//  Created by 白数叡司 on 2024/04/22.
//

import ComposableArchitecture
import Entity
import SwiftUI

// MARK: - Reducer
@Reducer
public struct RepositoryRow {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: Int { repository.id }
        let repository: Repository
    }
    
    public enum Action {
        /// 「RepositoryRowViewをタップ」を示すアクション
        case rowTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .rowTapped:
                return .none
            }
        }
    }
}

// MARK: - View
public struct RepositoryRowView: View {
    
    public init() {}
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RepositoryRowView()
}
