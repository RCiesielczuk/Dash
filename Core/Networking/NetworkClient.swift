import Foundation
import Combine

public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    public init(session: URLSession? = nil) {
        self.session = session ?? URLSession(configuration: .default)
    }
    
    public func send<T: Decodable>(_ request: NetworkRequest, decoder: JSONDecoder = .init()) -> AnyPublisher<NetworkResponse<T>, Error> {
        return session.dataTaskPublisher(for: request.urlRequest)
            .mapError { NetworkError.request($0) }
            .map { $0.data }
            .tryMap { result -> NetworkResponse<T> in
                do {
                    let decodedResponse = try decoder.decode(T.self, from: result)
                    return NetworkResponse(result: decodedResponse)
                } catch {
                    throw NetworkError.conversionFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
