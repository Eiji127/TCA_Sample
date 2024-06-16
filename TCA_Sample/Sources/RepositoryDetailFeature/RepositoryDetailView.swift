//
//  RepositoryDetailView.swift
//
//  Created by 白数叡司 on 2024/05/19.
//

import ComposableArchitecture
import Entity
import GithubAPIClient
import SwiftUI
import WebKit

@Reducer
public struct RepositoryDetail {
    @ObservableState
    public struct State: Equatable {
        let repository: Repository
        var isWebViewLoading = true
        var isLiked = false
        
        public init(repository: Repository) {
            self.repository = repository
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case liked
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .liked:
                return .none
            }
        }
    }
}

public struct RepositoryDetailView: View {
    @Bindable var store: StoreOf<RepositoryDetail>
    
    public init(store: StoreOf<RepositoryDetail>) {
        self.store = store
    }
    
    public var body: some View {
        SimpleWebView(
            url: store.repository.htmlUrl,
            isLoading: $store.isWebViewLoading
        )
        .overlay(alignment: .center) {
            if store.isWebViewLoading {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
              Button {
                  store.send(.liked)
              } label: {
                  if store.isLiked {
                      Image(systemName: "heart.fill")
                  } else {
                      Image(systemName: "heart")
                  }
              }
          }
        }
    }
}

struct SimpleWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    private let webView = WKWebView()
    
    func makeUIView(context: Context) -> some UIView {
        webView.load(.init(url: url))
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: SimpleWebView
        
        init(_ parent: SimpleWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}

#Preview {
    RepositoryDetailView(
        store: .init(
            initialState: RepositoryDetail.State(
                repository: .mock(id: 1)
            )
        ) {
            RepositoryDetail()
        }
    )
}
