import Foundation

import RealmSwift

protocol RealmMemoRepositoryType {
    
    func fetchRealmPath() -> URL
    func fetchRealm() -> Results<RealmMemo>
    func fetchRealmSort(sort: String, ascending: Bool) -> Results<RealmMemo>
    func fetchRealmFilterSearchByText(text: String) -> Results<RealmMemo>
    //    func fetchRealmFilter() -> Results<RealmMemo>
    func fetchRealmAddItem(item: RealmMemo)
    func fetchRealmDeleteItem(item: RealmMemo)
    
}

class RealmMemoRepository: RealmMemoRepositoryType {
    
    let localRealm = try! Realm()
    
    func fetchRealmPath() -> URL {
        return localRealm.configuration.fileURL!
    }
    
    func fetchRealm() -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).sorted(byKeyPath: "realmCreatedDate" , ascending: false)
    }
    
    func fetchRealmSort(sort: String, ascending: Bool) -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).sorted(byKeyPath: sort, ascending: ascending)
    }
    
    func fetchRealmFilterSearchByText(text: String) -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).filter("title CONTAINS[c] '\(text)' OR content CONTAINS[c] '\(text)'").sorted(byKeyPath: "realmCreatedDate", ascending: false)
    }
    
    //    func fetchRealmFilter() -> Results<RealmMemo> {
    //        <#code#>
    //    }
    
    func fetchRealmAddItem(item: RealmMemo) {
        do {
            try localRealm.write {
                localRealm.add(item)
                print("Realm에 데이터 추가 성공")
            }
        } catch let error {
            print("Realm에 데이터 추가 실패", error)
        }
    }
    
    func fetchRealmDeleteItem(item: RealmMemo) {
        do {
            try localRealm.write {
                localRealm.delete(item)
                print("Relam에서 데이터 제거 성공")
            }
        } catch let error {
            print("Realm에서 데이터 제거 실패", error)
        }
    }
}
