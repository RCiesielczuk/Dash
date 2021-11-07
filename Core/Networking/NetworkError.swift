import Foundation

public enum NetworkConversionError: Error {
    case emptyData
    case stringConversionFailed
}

public enum NetworkError: Error {
    case networkError(Error)
    case noResponse
    case unexpectedStatusCode(Int)
    case conversionFailed(Error, statusCode: Int?)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let networkError):
            return "A Network Error: \(networkError.localizedDescription)"
        case .noResponse:
            return "No response from server."
        case .unexpectedStatusCode(let statusCode):
            return "Unexpected status code: \(statusCode)"
        case .conversionFailed(let conversionError, let statusCode):
            var result = "Conversion failed: \(conversionError.localizedDescription)"
            if let statusCode = statusCode {
                result.append(", response status code: \(statusCode)")
            }
            return result
        }
    }
}
