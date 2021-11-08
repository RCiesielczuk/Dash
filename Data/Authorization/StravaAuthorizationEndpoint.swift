import Foundation

enum StravaAuthorizationEndpoint: Equatable {
    case token(StravaRequestTokenParams)
    case refreshToken(StravaRefreshTokenParams)
}

extension StravaAuthorizationEndpoint: Endpoint {
    var baseURL: URL {
        return URL(string: "https://www.strava.com/api/v3/")!
    }

    var path: String {
        "oauth/token"
    }

    var method: HTTPMethod { .post }

    var parameters: [String: String]? {
        switch self {
        case .token(let requestParams):
            return requestParams.params
        case .refreshToken(let requestParams):
            return requestParams.params
        }
    }

    var body: Encodable? { nil }

    var headers: [String: String]? { ["Accept": "application/json", "Content-Type": "application/json"] }
}
