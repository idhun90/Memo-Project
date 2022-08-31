import Foundation

import RealmSwift

class RealmMemo: Object {
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    @Persisted var realmTitle: String
    @Persisted var realmContent: String
    @Persisted var realmCreatedDate = Date()
    @Persisted var realmEditedDate: Date?
    @Persisted var realmPin: Bool
    
    convenience init(realmTitle: String, realmContent: String, realmCreatedDate: Date, realmEditedDate: Date?) {
        self.init()
        self.realmTitle = realmTitle
        self.realmContent = realmContent
        self.realmCreatedDate = realmCreatedDate
        self.realmEditedDate = realmEditedDate
        self.realmPin = false
    }
    
}
