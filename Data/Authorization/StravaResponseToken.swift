import Foundation

struct StravaResponseToken: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval
    let expiresIn: TimeInterval
}

extension StravaResponseToken: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
    }
}
