import Foundation

public struct DefaultNetworkResponse {
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: NetworkError?
    
    public var statusCode: Int? {
        return response?.statusCode
    }
    
    public init(data: Data?,
                response: URLResponse?,
                error: NetworkError?) {
        self.data = data
        self.response = response as? HTTPURLResponse
        self.error = error
    }
}

public struct NetworkResponse<Value> {
    public let response: HTTPURLResponse?
    public let data: Data?
    public let result: Result<Value, NetworkError>
    
    public var statusCode: Int? {
        return response?.statusCode
    }
    
    public init(data: Data?,
                response: URLResponse?,
                result: Result<Value, NetworkError>) {
        self.data = data
        self.response = response as? HTTPURLResponse
        self.result = result
    }
    
    public init<Original>(from: NetworkResponse<Original>, result: Result<Value, NetworkError>) {
        self.data = from.data
        self.response = from.response
        self.result = result
    }
}
