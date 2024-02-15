//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

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
