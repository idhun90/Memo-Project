import Foundation

import RealmSwift

class RealmMemo: Object {
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    @Persisted var realmOriginalText: String
    @Persisted var realmTitle: String
    @Persisted var realmContent: String?
    @Persisted var realmDate = Date()
    @Persisted var realmPin: Bool
    
    convenience init(realmOriginalText: String, realmTitle: String, realmContent: String?, realmDate: Date) {
        self.init()
        self.realmOriginalText = realmOriginalText
        self.realmTitle = realmTitle
        self.realmContent = realmContent
        self.realmDate = realmDate
        self.realmPin = false
    }
    
}
