import Foundation

public protocol NetworkClientProtocol {
    func send<Result: Decodable>(_ request: NetworkRequest, completion: @escaping (NetworkResponse<Result>) -> Void)
    
    func send<Result: Decodable>(_ request: NetworkRequest, decoder: JSONDecoder, completion: @escaping (NetworkResponse<Result>) -> Void)
        
    func send<Payload: Encodable>(_ request: NetworkRequest, payload: Payload, completion: @escaping (DefaultNetworkResponse) -> Void)
    
    func send<Payload: Encodable>(_ request: NetworkRequest, payload: Payload, completion: @escaping (NetworkResponse<Data>) -> Void)
    
    func send<Payload: Encodable, Result: Decodable>(_ request: NetworkRequest, payload: Payload, completion: @escaping (NetworkResponse<Result>) -> Void)
    
    func send<Payload: Encodable, Result: Decodable>(_ request: NetworkRequest, payload: Payload, decoder: JSONDecoder, completion: @escaping (NetworkResponse<Result>) -> Void)
}
