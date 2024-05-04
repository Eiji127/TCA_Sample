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
## 3. Previewによる動作確認のついて
- Viewをinitializeするとき、StoreOf<XXX>を提供する必要がある。
  - Storeのinitializerには以下の要素がある。
    - initialState
    - reducer
    - withDependencies
- Xcode Previewのinitializeで指定しているReducerに `._printChanges()` を付与すると以下のように、Reducerで起きたActionやStateの変化をログとして出力することができる。
        
  ```lldb
  received action:
  RepositoryList.Action.onAppear
  RepositoryList.State(
    _repositories: [],
  -   _isLoading: false
  +   _isLoading: true
  )

  received action:
  RepositoryList.Action.searchRepositoriesResponse(
    .success(
      [
        [0]: Repository(
          id: 15111821,
          fullName: "grafana/grafana",
          description: "The open and composable observability and data visualization platform. Visualize metrics, logs, and traces from multiple sources like Prometheus, Loki, Elasticsearch, InfluxDB, Postgres and many more. ",
          stargazersCount: 60288,
          language: "TypeScript",
          htmlUrl: URL(https://github.com/grafana/grafana)
        ),
        [1]: Repository(
          id: 7508411,
          fullName: "ReactiveX/RxJava",
          description: "RxJava – Reactive Extensions for the JVM – a library for composing asynchronous and event-based programs using observable sequences for the Java VM.",
          stargazersCount: 47627,
          language: "Java",
          htmlUrl: URL(https://github.com/ReactiveX/RxJava)
        ),
        
        ...
        
        [29]: Repository(
          id: 715082,
          fullName: "reactiveui/ReactiveUI",
          description: "An advanced, composable, functional reactive model-view-viewmodel framework for all .NET platforms that is inspired by functional reactive programming. ReactiveUI allows you to  abstract mutable state away from your user interfaces, express the idea around a feature in one readable place and improve the testability of your application.",
          stargazersCount: 7900,
          language: "C#",
          htmlUrl: URL(https://github.com/reactiveui/ReactiveUI)
        )
      ]
    )
  )
  RepositoryList.State(
    _repositories: [
  +     [0]: Repository(
  +       id: 15111821,
  +       fullName: "grafana/grafana",
  +       description: "The open and composable observability and data visualization platform. Visualize metrics, logs, and traces from multiple sources like Prometheus, Loki, Elasticsearch, InfluxDB, Postgres and many more. ",
  +       stargazersCount: 60288,
  +       language: "TypeScript",
  +       htmlUrl: URL(https://github.com/grafana/grafana)
  +     ),
  +     [1]: Repository(
  +       id: 7508411,
  +       fullName: "ReactiveX/RxJava",
  +       description: "RxJava – Reactive Extensions for the JVM – a library for composing asynchronous and event-based programs using observable sequences for the Java VM.",
  +       stargazersCount: 47627,
  +       language: "Java",
  +       htmlUrl: URL(https://github.com/ReactiveX/RxJava)
  +     ),

	  		...
			
  +     [29]: Repository(
  +       id: 715082,
  +       fullName: "reactiveui/ReactiveUI",
  +       description: "An advanced, composable, functional reactive model-view-viewmodel framework for all .NET platforms that is inspired by functional reactive programming.     ReactiveUI allows you to  abstract mutable state away from your user interfaces, express the idea around a feature in one readable place and improve the testability of your application.",
  +       stargazersCount: 7900,
  +       language: "C#",
  +       htmlUrl: URL(https://github.com/reactiveui/ReactiveUI)
  +     )
      ],
  -   _isLoading: true
  +   _isLoading: false
  )
  ```
## 4. IdentifiedArrayについて
- Row ReducerをList Reducerに結合する時に使用。
- 1つのList Reducerが、Row Reducerの集合体を保持するような構造を表現するのに、 `IdentifiedArray` というAPIを利用する。
- `IdentifiedArray` は  `Identifinable` な要素に特化したものとなっている。
- `IdentifiedArray` はIDとElementという2つのGenericsを満たすことで利用可能。
- `IdentifiedArray` は swift-identified-collectionsというライブラリに収録されている。
## 5. Binding Reducerについて
- Pure SwiftUIではBindingを実現するために@Bindingを使用するが、TCAでは@Bindingだけでなく、以下のAPIを使用する。
  - BindingAction
    - `BindableAction` と `BindableAction` がある。
    - BindingActionはReducer内のActionに加える。
    - `BindinableAction` Protocolに準拠させるためには以下のcaseをActionに追加する必要がある。            
    ```swift
    public enum Action: BindableAction {
    	...
    	case binding(BindingAction<State>)
    }
    ```
  - BindingReducer
    - BindingReducerはReducer内のbodyに追加する。                
    ```swift
    public var body: some ReducerOf<Self> {
    	BindingReducer()
      	Reduce { state, action in
    		...
      	case .binding:
      		return ...
      	}
    }
    ```
    - Binding Valueとして提供するStateとBindingActionを機能させることができる。
- View側でBindingを実装するためには以下の内容をView側に追加する必要がある。
  - iOS17以降の場合は、@Binableを利用したプロパティ
  - iOS16以前の場合は、swift-perception に用意されている `@Perception.Bindable` を代わりに利用する必要がある。
- BindingしたプロパティはReducerのbody内で以下のように設定する。
    - 今回だとqueryをバインディングしたいため、queryを設定。
    ```swift
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            ...
            case .binding(\.query):
                return ...
            ...
            }
        }
    }
    ```
## 6. Debounce設定について
- TCAにはDebounceを設定するための APIとして、 `Effect.debounce(id:for:scheduler:)` が用意されている。
- Effect.runにつけることで実装可能。
## 7. Xcode Previewの改善について
- Previews は View や挙動をサイクル早く修正できることがメリット
- Xcode Previewで実際のAPIを叩いて表示しているのはあまり良くない。
- Swiftにおけるinterfaceはprotocolで定義しがち。
  - TCA (Point-free) では、structのclosure propertiesで表現することを推奨している。
  - structでinterfaceを定義することで、swift-dependenciesと親和性の高いコードが書ける。(詳しくは[swift-dependencies のドキュメント](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/designingdependencies))
  - structの方法で依存関係を制御することで、機能に必要な依存関係エンドポイントを選択ことができる。
    - ex. structで定義したAudioPlayerというinterfaceがあり、play、stop、….などの関数があったとき、playしか呼び出す必要がないときにplayのみを選択することができ、不要な処理まで読み込む必要はなくなる。
- swift-dependencies は Point-Free 製の依存関係を管理するためのライブラリ。
  - swift-dependencies を利用するために `Dependencies` を import する必要がある。
  - swift-dependenciesの`Dependencies` 内にあるDependencyKeyというprotocolをClientに準拠する。
  - `TestDependencyKey` という protocolがある。
    - Xcode Previews とテストのために依存関係を提供するKey
    - ClientにはpreviewValueを定義する。
    - `previewValue` は Xcode Previews のための依存関係としての機能
      - 基本的には何もしない実装 (no operation) に近い形で提供することが推奨されている。
    - `testValue` はテストのための依存関係としての機能
      - 実装はPoint-freeの慣習に則り、xctest-dynamic-overlay というライブラリに定義されている `unimplemented` を利用する。
      - `unimplemented` は`XCTFail` を内部で利用しているため、もしテストで依存関係を適切に上書きしなかった場合、テストを失敗させてくれるようになっている。
  - DependencyKeyはすでにTestDependencyKeyを準拠しているため、DependencyKeyのみでpreviewValueとtestValueを定義することができる。
    - ただ、実装部分を明確に区切ることができたり、意識して使えばモジュール分離の観点で、別々に定義した方がメリットがある。
  - swift-dependencies に用意されている `@DepenedencyClient` macro を利用することも可能。
## 8. TCAにおけるUnit Testについて
- TCAのテストサポート機能は基本的にMainActorのcontextで動作することが前提となっている。
  - そのため、テストクラスには＠MainActorを付与しておく必要がある。
- ロジックはReducerにまとめられているため、基本的にはReducerのテストを書いていく。
- 実動作ではReducerを駆動するランタイムとしてStoreを使用するが、テストの時はテスト用のランタイムとしてTestStoreを用いる。
  - TestStoreは通常のStoreと同様に引数にinitialStateとReducerを提供することで初期化することができる。
  ```swift
  let store = TestStore(
    initialState: RepositoryList.State()
  ) {
    RepositoryList()
  }
  ```      
- TCAには以下のテストエラーが表示される。
  - Unhandled actions：本来発生するはずの Action をテストで Assert できていないため発生するエラー。
  - Unimplemented：テストで依存関係を適切に上書きしなかった場合に発生するテストエラー。意図していない依存関係が呼ばれていることにテストで気づくことができる。
  
  ![スクリーンショット 2024-05-05 0 22 01](https://github.com/Eiji127/TCA_Sample/assets/64912886/ed079d24-3548-4828-86f9-b5cde9c4c9c6)
  
- Reducerの処理の流れで発生するはずのActionをAssertするためには、 `receive`functionを使用する。
  - KeyPathを引数に受け取ることでassociated valueが必要なActionのcaseを、associated valueの指定なしで記述することができる。
