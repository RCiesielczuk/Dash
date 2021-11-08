import Combine
import Foundation
import AuthenticationServices

protocol StravaAuthorizationInteractorProtocol {
    func authorize()
}

final class StravaAuthorizationInteractor: NSObject, StravaAuthorizationInteractorProtocol {
    private let repository: StravaAuthorizationRepositoryProtocol
    var subscriptions: Set<AnyCancellable> = []
    
    init(repository: StravaAuthorizationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func authorize() {
        repository.getAuthorization(with: self).sink { result in
            switch result {
            case .failure(let error):
                print("ERROR is: \(error)")
            case .finished:
                print("FINISHED")
            }
        } receiveValue: { token in
            self.processResponseUrl(token)
        }.store(in: &subscriptions)
    }
    
    private func processResponseUrl(_ token: StravaToken) {
        print("completion: \(token)")
    }
}

extension StravaAuthorizationInteractor: ASWebAuthenticationPresentationContextProviding {
    var currentWindow: UIWindow? { return UIApplication.shared.windows.first }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        currentWindow ?? ASPresentationAnchor()
    }
}
