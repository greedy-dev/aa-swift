//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import Foundation

import Foundation
import web3
import BigInt

public struct PimlicoGasAndPaymasterAndData: Codable {
    private enum CodingKeys: String, CodingKey {
        case paymasterAndData
        case preVerificationGasStr = "preVerificationGas"
        case verificationGasStr = "verificationGas"
        case verificationGasLimitStr = "verificationGasLimit"
        case callGasLimitStr = "callGasLimit"

        case error
    }
    
    let paymasterAndData: String
    let preVerificationGasStr: String
    let verificationGasStr: String
    let verificationGasLimitStr: String
    let callGasLimitStr: String
    
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
}
