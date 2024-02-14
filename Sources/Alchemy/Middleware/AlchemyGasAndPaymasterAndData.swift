import Foundation
import web3
import BigInt

public struct AlchemyGasAndPaymasterAndData: Codable {
    private enum CodingKeys: String, CodingKey {
        case paymasterAndData
        case callGasLimitStr = "callGasLimit"
        case verificationGasLimitStr = "verificationGasLimit"
        case preVerificationGasStr = "preVerificationGas"
        case maxFeePerGasStr = "maxFeePerGas"
        case maxPriorityFeePerGasStr = "maxPriorityFeePerGas"
        case error
    }
    
    let paymasterAndData: String
    let callGasLimitStr: String
    let verificationGasLimitStr: String
    let preVerificationGasStr: String
    let maxFeePerGasStr: String
    let maxPriorityFeePerGasStr: String
    let error: ErrorObject?
    
    public var callGasLimit: BigUInt {
        return BigUInt(hex: callGasLimitStr)!
    }

    public var verificationGasLimit: BigUInt {
        return BigUInt(hex: verificationGasLimitStr)!
    }

    public var preVerificationGas: BigUInt {
        return BigUInt(hex: preVerificationGasStr)!
    }
    
    public var maxFeePerGas: BigUInt {
        return BigUInt(hex: maxFeePerGasStr)!
    }
    
    public var maxPriorityFeePerGas: BigUInt {
        return BigUInt(hex: maxPriorityFeePerGasStr)!
    }
}
