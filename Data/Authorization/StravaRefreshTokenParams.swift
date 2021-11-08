import Foundation

struct StravaRefreshTokenParams: Equatable {
    let id: String
    let secret: String
    let code: String
    let refreshToken: String
    
    var params: [String: String] {
        [
            "client_id": id,
            "client_secret": secret,
            "code": code,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
    }
}
