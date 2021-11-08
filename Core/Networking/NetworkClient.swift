import Foundation
import Combine

public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    public init(session: URLSession?) {
        self.session = session ?? URLSession(configuration: .default)
    }
    
    public func send<T: Decodable>(_ request: NetworkRequest, decoder: JSONDecoder = .init()) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request.urlRequest)
            .mapError { NetworkError.request($0) }
            .map { $0.data }
            .flatMap {
                Just($0)
                    .decode(type: T.self, decoder: decoder)
                    .mapError { NetworkError.conversionFailed($0) }}
            .eraseToAnyPublisher()
    }
}
