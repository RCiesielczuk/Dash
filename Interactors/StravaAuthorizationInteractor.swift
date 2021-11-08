import Combine
import Foundation
import AuthenticationServices

protocol StravaAuthorizationInteractorProtocol {
    func signIn()
}

final class StravaAuthorizationInteractor: NSObject, StravaAuthorizationInteractorProtocol {
    private let repository: StravaAuthorizationRepositoryProtocol
    var subscriptions: Set<AnyCancellable> = []
    
    init(repository: StravaAuthorizationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func signIn() {
        repository.getAuthorization(with: self).sink { error in
            print(error)
        } receiveValue: { url in
            self.processResponseUrl(url)
        }.store(in: &subscriptions)
    }
    
    private func processResponseUrl(_ url: String) {
        print("completion: \(url)")
    }
}

extension StravaAuthorizationInteractor: ASWebAuthenticationPresentationContextProviding {
    var currentWindow: UIWindow? { return UIApplication.shared.windows.first }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        currentWindow ?? ASPresentationAnchor()
    }
}
