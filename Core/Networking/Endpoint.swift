import Foundation

public protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
}
