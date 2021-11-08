import Foundation

struct StravaRequestTokenParams: Equatable {
    let id: Int
    let secret: String
    let code: String
    
    var params: [String: String] {
        [
            "client_id": String(id),
            "client_secret": secret,
            "code": code,
            "grant_type": "authorization_code"
        ]
    }
}
