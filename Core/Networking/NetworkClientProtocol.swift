import Foundation
import Combine


public protocol NetworkClientProtocol {
    func send<T: Decodable>(_ request: NetworkRequest, decoder: JSONDecoder) -> AnyPublisher<T, Error>
}
