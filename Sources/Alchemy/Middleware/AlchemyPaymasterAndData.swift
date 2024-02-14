import web3
import Foundation

public struct ErrorObject: Equatable, Codable {
    public enum CodingKeys: String, CodingKey {
        case code
        case message
    }
    
    public let code: Int
    public let message: String
}

public struct AlchemyPaymasterAndData: Equatable, Codable {
    public let paymasterAndData: String
    public let error: ErrorObject?

    public enum CodingKeys: String, CodingKey {
        case paymasterAndData
        case error
    }
}
