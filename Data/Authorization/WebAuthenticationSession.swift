import Foundation
import AuthenticationServices

public typealias WebAuthenticationSessionFactory = (URL, String?, @escaping ASWebAuthenticationSession.CompletionHandler) -> (ASWebAuthenticationSession)
