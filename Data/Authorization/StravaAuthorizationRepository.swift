import Combine
import Foundation
import AuthenticationServices

protocol StravaAuthorizationRepositoryProtocol {
    func getAuthorization(with contextProvider: ASWebAuthenticationPresentationContextProviding) -> AnyPublisher<String, Error>
}

enum StravaAuthorizationError: Error {
    case missingUrlAfterAuthorization
}

final class StravaAuthorizationRepository: StravaAuthorizationRepositoryProtocol {
    private let config: StravaConfig
    private let authenticationSession: WebAuthenticationSessionFactory
    
    init(config: StravaConfig, authenticationSession: WebAuthenticationSessionFactory? = nil) {
        self.config = config
        
        if let authenticationSession = authenticationSession {
            self.authenticationSession = authenticationSession
        } else {
            self.authenticationSession = { url, callbackURLScheme, completionHandler in
                return ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            }
        }
    }
    
    func getAuthorization(with contextProvider: ASWebAuthenticationPresentationContextProviding) -> AnyPublisher<String, Error> {
        getCode(contextProvider).flatMap { [self] in getAuthToken($0) }.eraseToAnyPublisher()
    }
    
    private func getCode(_ contextProvider: ASWebAuthenticationPresentationContextProviding) -> Future<URL, Error> {
        return Future<URL, Error> { promise in
            let session = self.authenticationSession(self.buildUrl(), "runner-dash") { (url, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let url = url else {
                    promise(.failure(StravaAuthorizationError.missingUrlAfterAuthorization))
                    return
                }
                promise(.success(url))
            }
            session.presentationContextProvider = contextProvider
            session.start()
        }
    }
    
    private func getAuthToken(_ url: URL) -> Future<String, Error> {
        return Future<String, Error> { promise in
            promise(.success("RESULT IS: \(url.absoluteString)"))
        }
    }
    
    private func buildUrl() -> URL {
        return URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=\(config.clientId)&redirect_uri=\(config.redirectUri)&scope=\(config.scope)&response_type=code&approval_prompt=auto")!
    }
}
