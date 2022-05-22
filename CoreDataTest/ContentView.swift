//
//  ContentView.swift
//  CoreDataTest
//
//  Created by 新川竜司 on 2022/03/27.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // 被管理オブジェクトコンテキスト(ManegedObjectContext)の取得
    // このオブジェクトを使ってデータベースアクセスの全ての操作を行う
    @Environment(\.managedObjectContext) private var viewContext
    // データベースよりデータを取得
    // ソート条件：timestamp属性の昇順、アニメーションタイプ：標準
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    // 取得結果が格納されるitemsは被管理オブジェクト（ManagedObject）のコレクションであるFetchedResults<Item>型
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView { // ナビゲーションバーを表示するために必要
            List {
                // 取得したデータリストを表示
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                // メモ削除のモディファイアとメソッド
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                // ナビゲーションバーの右側(Trailing)にEditButtonを表示
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                // ナビゲーションバーの右側に＋ボタンを表示
                ToolbarItem {
                    // 行追加のボタン
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }
    // 行追加のメソッド
    private func addItem() {
        withAnimation {
            // 新規レコードの作成
            // Itemクラスのインスタンスを作成
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                // データベースの保存、エラー発生のため、try-catch文で使用
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                // このメソッドにより、クラッシュログを残して終了する
                // リリース時は削除が必要
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    // メモ削除のメソッド
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // 削除対象の要素にviewContext(managedObjectContextクラス)のdeleteメソッドを適用して削除する
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                // データベースの保存、エラー発生のため、try-catch文で使用　行追加と同じ処理
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                // このメソッドにより、クラッシュログを残して終了する
                // リリース時は削除が必要　行追加と同じ処理
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
// item.timestampの出力形式を指定
// LocalizedStringKey型での記述方法
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // ManagedObjectContextを環境変数に設定(preview用)
        // 通常用途の違いは①preview用の初期データが生成される、②DBが実ファイルでなくメモリ上に構築される(コミットしても永続化されない)
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
