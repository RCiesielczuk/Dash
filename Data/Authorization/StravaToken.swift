import Foundation

struct StravaToken: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval
}

extension StravaToken: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
}
