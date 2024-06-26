//
//  SwiftUI_TCA_SampleApp.swift
//  SwiftUI_TCA_Sample
//
//  Created by 白数叡司 on 2024/03/10.
//

import RepositoryListFeature
import SwiftUI

@main
struct SwiftUI_TCA_SampleApp: App {
    var body: some Scene {
        WindowGroup {
            RepositoryListView(
                store: .init(
                    initialState: RepositoryList.State()
                ) {
                    RepositoryList()._printChanges()
                }
            )
        }
    }
}
