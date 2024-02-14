import Foundation
import BigInt

public struct EstimateUserOperationGasResponse: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case preVerificationGasStr = "preVerificationGas"
        case verificationGasLimitStr = "verificationGasLimit"
        case callGasLimitStr = "callGasLimit"
    }

    private let preVerificationGasStr: String
    private let verificationGasLimitStr: String
    private let callGasLimitStr: String

    public var preVerificationGas: BigUInt {
        return BigUInt(hex: preVerificationGasStr)!
    }

    public var verificationGasLimit: BigUInt {
        return BigUInt(hex: verificationGasLimitStr)!
    }

    public var callGasLimit: BigUInt {
        return BigUInt(hex: callGasLimitStr)!
    }
}
