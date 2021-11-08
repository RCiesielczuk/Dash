import Foundation
import AuthenticationServices

public typealias StravaWebAuthenticationSessionFactory = (URL, String?, @escaping ASWebAuthenticationSession.CompletionHandler) -> (ASWebAuthenticationSession)
