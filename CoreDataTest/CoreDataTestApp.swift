//
//  CoreDataTestApp.swift
//  CoreDataTest
//
//  Created by 新川竜司 on 2022/03/27.
//

import SwiftUI

@main
struct CoreDataTestApp: App {
    // 永続コンテナのコントローラ生成
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                // ManagedObjectContextを環境変数に追加(通常用)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
