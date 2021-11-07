import Foundation

public extension NetworkingProvider {
    enum Error: Swift.Error {
        case couldNotBuildURLComponents(_ partialURL: URL)
        case couldNotBuildURL(_ partialURL: URL, parameters: [String: String]?)
    }
}

public class NetworkingProvider<E: Endpoint> {
    private let decoder: JSONDecoder
    private let networkClient: NetworkClient
    
    public init(decoder: JSONDecoder = .init(),
                networkClient: NetworkClient) {
        self.decoder = decoder
        self.networkClient = networkClient
    }
    
    public func execute<T: Decodable>(_ endpoint: E, completion: ((Result<T, Swift.Error>) -> Void)?) {
        do {
            let request = try makeRequest(for: endpoint)
            if let payload = endpoint.body.map({ ConcreteEncodable($0) }) {
                networkClient.send(request, payload: payload, decoder: decoder) { [weak self] (response: NetworkResponse<T>) in
                    self?.handle(response, for: request, completion: completion)
                }
            } else {
                networkClient.send(request, decoder: decoder) { [weak self] (response: NetworkResponse<T>) in
                    self?.handle(response, for: request, completion: completion)
                }
            }
        } catch {
            completion?(.failure(error))
        }
    }
    
    // MARK: Request Factory
    
    private func makeURL(for endpoint: E) throws -> URL {
        let partialURL = (endpoint.baseURL).appendingPathComponent(endpoint.path)
        guard var components = URLComponents(url: partialURL, resolvingAgainstBaseURL: false) else {
            throw Error.couldNotBuildURLComponents(partialURL)
        }
        
        if let parameters = endpoint.parameters {
            var queryItems = [URLQueryItem]()
            parameters.forEach { queryItems.append(URLQueryItem(name: $0.key, value: $0.value)) }
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw Error.couldNotBuildURL(partialURL, parameters: endpoint.parameters)
        }
        
        return url
    }
    
    private func makeRequest(for endpoint: E) throws -> NetworkRequest {
        let url = try makeURL(for: endpoint)
        
        let request: NetworkRequest = {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = endpoint.method.rawValue
            urlRequest.allHTTPHeaderFields = endpoint.headers
            return NetworkRequest(urlRequest: urlRequest)
        }()
        
        return request
    }
    
    // MARK: Response Handlers
    
    private func handle<T>(_ response: NetworkResponse<T>, for request: NetworkRequest, completion: ((Result<T, Swift.Error>) -> Void)?) {
        switch response.result {
        case .success(let result):
            completion?(.success(result))
        case .failure(let error):
            completion?(.failure(error))
        }
    }
    
}

/// When calling generic functions (like `NetworkClient.send<P: Encodable>(request: _, payload: P, _)`
/// we need to pass concrete types that conform to the generic requirements. For example, for the example above, we would need
/// to send an object conforming to `Encodable` as the payload. If we try to pass a non-concrete `Encodable` object, we will get this error:
/// "Protocol type 'Encodable' cannot conform to 'Encodable' because only concrete types can conform to protocols".
/// By creating this `ConcreteEncodable` box that wraps a non-concrete `Encodable` object, we can bypass the limitations.
internal struct ConcreteEncodable: Encodable {
    let wrapped: Encodable
    
    init(_ wrapped: Encodable) {
        self.wrapped = wrapped
    }
    
    func encode(to encoder: Encoder) throws {
        try wrapped.encode(to: encoder)
    }
}
