import Combine
import Foundation
import AuthenticationServices

protocol StravaAuthorizationRepositoryProtocol {
    func getAuthorization(with contextProvider: ASWebAuthenticationPresentationContextProviding) -> AnyPublisher<StravaToken, Error>
}

enum StravaAuthorizationError: Error {
    case authorization(Error)
    case missingUrlAfterAuthorization
    case missingCode
}

final class StravaAuthorizationRepository: StravaAuthorizationRepositoryProtocol {
    private let config: StravaConfig
    private let networkingProvider: NetworkingProvider<StravaAuthorizationEndpoint>
    private let authenticationSession: StravaWebAuthenticationSessionFactory
    
    init(config: StravaConfig,
         networkingProvider: NetworkingProvider<StravaAuthorizationEndpoint>,
         authenticationSession: StravaWebAuthenticationSessionFactory? = nil) {
        self.config = config
        self.networkingProvider = networkingProvider
        
        if let authenticationSession = authenticationSession {
            self.authenticationSession = authenticationSession
        } else {
            self.authenticationSession = { url, callbackURLScheme, completionHandler in
                return ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            }
        }
    }
    
    func getAuthorization(with contextProvider: ASWebAuthenticationPresentationContextProviding) -> AnyPublisher<StravaToken, Error> {
        getCode(contextProvider).flatMap(self.getAuthToken).eraseToAnyPublisher()
    }
    
    private func getCode(_ contextProvider: ASWebAuthenticationPresentationContextProviding) -> Future<String, Error> {
        return Future<String, Error> { promise in
            let session = self.authenticationSession(self.buildUrl(), "runner-dash") { (url, error) in
                if let error = error {
                    promise(.failure(StravaAuthorizationError.authorization(error)))
                    return
                }
                guard let url = url else {
                    promise(.failure(StravaAuthorizationError.missingUrlAfterAuthorization))
                    return
                }
                guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
                    promise(.failure(StravaAuthorizationError.missingCode))
                    return
                }
                promise(.success(code))
            }
            session.presentationContextProvider = contextProvider
            session.start()
        }
    }
    
    private func getAuthToken(_ code: String) -> AnyPublisher<StravaToken, Error> {
        let params = StravaRequestTokenParams(id: config.clientId, secret: config.clientSecret, code: code)
        return networkingProvider.execute(.token(params)).eraseToAnyPublisher()
    }
    
    private func buildUrl() -> URL {
        return URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=\(config.clientId)&redirect_uri=\(config.redirectUri)&scope=\(config.scope)&response_type=code&approval_prompt=auto")!
    }
}
