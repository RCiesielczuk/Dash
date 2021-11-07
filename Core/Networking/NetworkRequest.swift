import Foundation

public struct NetworkRequest: Equatable {
    public let urlRequest: URLRequest
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    public func adding(_ payload: Data) -> NetworkRequest {
        var requestWithPayload = self.urlRequest
        requestWithPayload.httpBody = payload
        return NetworkRequest(urlRequest: requestWithPayload)
    }
    
    public func adding<Payload: Encodable>(_ payload: Payload) throws -> NetworkRequest {
        let encodedPayload = try JSONEncoder().encode(payload)
        return self.adding(encodedPayload)
    }
    
    public static func request(_ url: URL,
                               queryItems: [URLQueryItem]? = nil,
                               httpHeaders: [String: String]? = nil) -> NetworkRequest {
        var urlRequest = URLRequest(url: url)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }

        if let httpHeaders = httpHeaders {
            urlRequest.allHTTPHeaderFields = httpHeaders
        }
        urlRequest.url = components.url

        return NetworkRequest(urlRequest: urlRequest)
    }
}
