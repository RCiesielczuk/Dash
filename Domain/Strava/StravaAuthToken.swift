import Foundation

public struct StravaAuthToken: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval
    let expiresIn: TimeInterval
}


extension StravaAuthToken {
    init(_ responseToken: StravaResponseToken) {
        self.accessToken = responseToken.accessToken
        self.refreshToken = responseToken.refreshToken
        self.expiresAt = responseToken.expiresAt
        self.expiresIn = responseToken.expiresIn
    }
}
