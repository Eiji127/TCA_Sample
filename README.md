# ■ Sample App with The Composable Architecture

## 0. SPMによるマルチモジュール化について
- 以下の記事を参考に行うことができる。

  https://zenn.dev/kalupas226/articles/73118709e316ad
        
## 1. Reducerについて
- Reducerには以下の3つの要素が必要
  - State
    - テストでStateの変化をassertionできるようにするために、TCAのおけるStateはEquatableを準拠している。
      ```swift
      @ObservableState
      public struct State: Equatable {
        var repositories: [Repository] = []
        var isLoading: Bool = false
                
        public init() {}
      }
      ```
  - Action
    ```swift
    public enum Action {
    /// 「画面の表示」を示すアクション
    case onAppear
    /// 「GitHub API Request の結果の取得」を示すアクション
    case searchRepositoriesResponse(Result<[Repository], Error>)
    }
    ```
  - body
    - bodyは以下の責務がある。
      - 何らかのActionが与えられた時に、Stateを現在の値から次の値へと変更する責務
        - アプリが外の世界で実行すべき処理であるEffectを返却する責務
          - ex. API通信、UserDefaultsへのアクセス　　など
    - 以上の責務をReduceというAPIで実現する。
    - ReducerOf<Self>はReducer<Self.State, Self.Action>のtypealias
## 2. Storeについて
- ReducerとViewを繋ぎ込むためのAPI
- 機能におけるランタイムとしての責務
  - Reducerの実装に則ってStateを更新するためにActionを処理したり、Effectを実行したりする。
- StoreOf<XXX>はStore<XXX.State, XXX.Action>のtypealias
- iOS16以前をサポートする場合は、Observation の backport framework である swift-perception の `WithPerceptionTracking` で各 View を包む必要がある (詳しくは[Observation backport](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/observationbackport))。iOS17以降ではObservation frameworkが利用可能のため、不要。
- .onAppearのタイミングでReducerの定義した.onAppearを発火させている。        
  ```swift
  public var body: some View {
    Group {
      ...
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
  ```
