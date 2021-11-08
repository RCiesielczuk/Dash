import Foundation

public struct NetworkResponse<Wrapped: Decodable>: Decodable {
    var result: Wrapped
}
