import Foundation

public enum NetworkingProviderError: Error {
    case couldNotBuildURLComponents(_ partialURL: URL)
    case couldNotBuildURL(_ partialURL: URL, parameters: [String: String]?)
}

public enum NetworkError: Error {
    case request(Error)
    case noResponse
    case unexpectedStatusCode(Int)
    case conversionFailed(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .request(let networkError):
            return "A Request Error: \(networkError.localizedDescription)"
        case .noResponse:
            return "No response from server."
        case .unexpectedStatusCode(let statusCode):
            return "Unexpected status code: \(statusCode)"
        case .conversionFailed(let conversionError):
            return "Conversion failed: \(conversionError.localizedDescription)"
        }
    }
}
