import Foundation
import UIKit

class DashAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let config = StravaConfig(clientId: StravaConstants.clientId,
                                  clientSecret: StravaConstants.clientSecret,
                                  redirectUri: StravaConstants.clientRedirectUri)
        let repository = StravaAuthorizationRepository(config: config, networkingProvider: .init(networkClient: .init()))
        
        let interactor = StravaAuthorizationInteractor(repository: repository)
        interactor.authorize()
        
        return true
    }
}
