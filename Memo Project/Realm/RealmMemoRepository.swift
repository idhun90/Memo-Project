import Foundation

import RealmSwift

protocol RealmMemoRepositoryType {
    
    func fetchRealmPath() -> URL
    func fetchRealm() -> Results<RealmMemo>
    func fetchRealmPin() -> Results<RealmMemo>
    func fetchRealmNoPin() -> Results<RealmMemo>
    func fetchRealmSort(sort: String, ascending: Bool) -> Results<RealmMemo>
    func fetchRealmFilterSearchByText(text: String) -> Results<RealmMemo>
    //    func fetchRealmFilter() -> Results<RealmMemo>
    func fetchRealmAddItem(item: RealmMemo)
    func fetchRealmDeleteItem(item: RealmMemo)
    func fetchRealmChangePin(item: RealmMemo)
    func fetchRealmUpdate(objectId: ObjectId, originalText: String, title: String, content: String?, editedDate: Date)
    
}

class RealmMemoRepository: RealmMemoRepositoryType {
    
    let localRealm = try! Realm()
    
    func fetchRealmPath() -> URL {
        return localRealm.configuration.fileURL!
    }
    
    func fetchRealm() -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).sorted(byKeyPath: "realmDate" , ascending: false)
    }
    
    func fetchRealmPin() -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).filter("realmPin = true").sorted(byKeyPath: "realmDate" , ascending: false)
    }
    
    func fetchRealmNoPin() -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).filter("realmPin = false").sorted(byKeyPath: "realmDate" , ascending: false)
    }
    
    func fetchRealmSort(sort: String, ascending: Bool) -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).sorted(byKeyPath: sort, ascending: ascending)
    }
    
    func fetchRealmFilterSearchByText(text: String) -> Results<RealmMemo> {
        return localRealm.objects(RealmMemo.self).filter("realmTitle CONTAINS[c] '\(text)' OR realmContent CONTAINS[c] '\(text)'").sorted(byKeyPath: "realmDate", ascending: false)
    }

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
    func fetchRealmChangePin(item: RealmMemo) {
        do {
            try localRealm.write {
                item.realmPin = !item.realmPin
                print("Pin값 변환 성공")
            }
        } catch let error {
            print("Pin값 변환 실패", error)
        }
    }
    
    func fetchRealmUpdate(objectId: ObjectId, originalText: String, title: String, content: String?, editedDate: Date) {
        do {
            try localRealm.write {
                localRealm.create(RealmMemo.self, value: ["objectId": objectId, "realmOriginalText": originalText, "realmTitle": title, "realmContent": content ?? "", "realmDate": editedDate], update: .modified)
            }
        } catch let error {
            print("데이터 업데이트 실패", error)
        }
    }
}
