import Foundation

public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    public init(session: URLSession?) {
        self.session = session ?? URLSession(configuration: .default)
    }
    
    public func send(_ request: NetworkRequest, completion: @escaping (DefaultNetworkResponse) -> Void) {
        let dataTask = session.dataTask(with: request.urlRequest) { (data, response, error) in
            if let error = error {
                let response = DefaultNetworkResponse(data: data, response: response, error: NetworkError.networkError(error))
                completion(response)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let response = DefaultNetworkResponse(data: nil, response: nil, error: NetworkError.noResponse)
                completion(response)
                return
            }
            
            guard (200..<300).contains(response.statusCode) else {
                let response = DefaultNetworkResponse(data: nil, response: response, error: NetworkError.unexpectedStatusCode(response.statusCode))
                completion(response)
                return
            }
            
            let defaultResponse = DefaultNetworkResponse(data: data, response: response, error: nil)
            completion(defaultResponse)
        }
        dataTask.resume()
    }
    
    public func send(_ request: NetworkRequest, completion: @escaping (NetworkResponse<Data>) -> Void) {
        send(request) { (response: DefaultNetworkResponse) in
            if let error = response.error {
                let response = NetworkResponse<Data>(data: nil,
                                                     response: response.response,
                                                     result: .failure(error))
                completion(response)
                return
            }
            
            guard let data = response.data, data.count > 0 else {
                let response = NetworkResponse<Data>(data: nil,
                                                     response: response.response,
                                                     result: .failure(.conversionFailed(NetworkConversionError.emptyData, statusCode: response.statusCode)))
                completion(response)
                return
            }
            
            let response = NetworkResponse<Data>(data: data, response: response.response, result: .success(data))
            completion(response)
        }
    }
    
    public func send(_ request: NetworkRequest, completion: @escaping (NetworkResponse<String>) -> Void) {
        send(request) { (response: NetworkResponse<Data>)  in
            switch response.result {
            case .failure(let error):
                let response = NetworkResponse<String>(from: response, result: .failure(error))
                completion(response)
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else {
                    let response = NetworkResponse<String>(from: response,
                                                           result: .failure(.conversionFailed(NetworkConversionError.stringConversionFailed,
                                                                                              statusCode: response.statusCode)))
                    completion(response)
                    return
                }
                
                let response = NetworkResponse<String>(from: response, result: .success(string))
                completion(response)
            }
        }
    }
    
    public func send<Result: Decodable>(_ request: NetworkRequest, completion: @escaping (NetworkResponse<Result>) -> Void) {
        send(request, decoder: JSONDecoder(), completion: completion)
    }
    
    public func send<Result: Decodable>(_ request: NetworkRequest, decoder: JSONDecoder, completion: @escaping (NetworkResponse<Result>) -> Void) {
        self.send(request) { (response: NetworkResponse<Data>)  in
            switch response.result {
                
            case .failure(let error):
                let response = NetworkResponse<Result>(from: response, result: .failure(error))
                completion(response)
                
            case .success(let data):
                let decodedJSON: Result
                do {
                    decodedJSON = try decoder.decode(Result.self, from: data)
                } catch {
                    print(error)
                    let response = NetworkResponse<Result>(from: response, result: .failure(.conversionFailed(error, statusCode: response.statusCode)))
                    completion(response)
                    return
                }
                
                let response = NetworkResponse<Result>(from: response, result: .success(decodedJSON))
                completion(response)
            }
        }
    }
    
    public func send<Payload: Encodable>(_ request: NetworkRequest, payload: Payload, completion: @escaping (DefaultNetworkResponse) -> Void) {
        do {
            let requestWithPayload = try request.adding(payload)
            send(requestWithPayload, completion: completion)
        } catch {
            let response = DefaultNetworkResponse(data: nil, response: nil, error: NetworkError.conversionFailed(error, statusCode: nil))
            completion(response)
        }
    }
    
    public func send<Payload: Encodable, Result: Decodable>(_ request: NetworkRequest, payload: Payload, completion: @escaping (NetworkResponse<Result>) -> Void) {
        send(request, payload: payload, decoder: .init(), completion: completion)
    }
    
    public func send<Payload: Encodable, Result: Decodable>(_ request: NetworkRequest, payload: Payload, decoder: JSONDecoder, completion: @escaping (NetworkResponse<Result>) -> Void) {
        var requestWithPayload: NetworkRequest
        do {
            requestWithPayload = try request.adding(payload)
            send(requestWithPayload, decoder: decoder, completion: completion)
        } catch {
            let response = NetworkResponse<Result>(data: nil, response: nil, result: .failure(.conversionFailed(error, statusCode: nil)))
            completion(response)
        }
    }
}
