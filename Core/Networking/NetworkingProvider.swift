import Foundation
import Combine

public class NetworkingProvider<E: Endpoint> {
    private let networkClient: NetworkClient
    private let decoder: JSONDecoder

    public init(networkClient: NetworkClient, decoder: JSONDecoder = .init()) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
        
    public func execute<T: Decodable>(_ endpoint: E) -> AnyPublisher<T, Error> {
        do {
            let request = try makeRequest(for: endpoint)
            return networkClient.send(request, decoder: decoder).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: Request Factory
    
    private func makeURL(for endpoint: E) throws -> URL {
        let partialURL = (endpoint.baseURL).appendingPathComponent(endpoint.path)
        guard var components = URLComponents(url: partialURL, resolvingAgainstBaseURL: false) else {
            throw NetworkingProviderError.couldNotBuildURLComponents(partialURL)
        }
        
        if let parameters = endpoint.parameters {
            var queryItems = [URLQueryItem]()
            parameters.forEach { queryItems.append(URLQueryItem(name: $0.key, value: $0.value)) }
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw NetworkingProviderError.couldNotBuildURL(partialURL, parameters: endpoint.parameters)
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
}
