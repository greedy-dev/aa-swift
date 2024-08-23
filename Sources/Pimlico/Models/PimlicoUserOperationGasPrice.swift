//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import Foundation
import BigInt

public struct PimlicoUserOperationGasPrice: Codable {
    let slow: GasPrice
    let standard: GasPrice
    let fast: GasPrice
}

public struct GasPrice: Codable {
    enum CodingKeys: String, CodingKey {
        case maxFeePerGasStr = "maxFeePerGas"
        case maxPriorityFeePerGasStr = "maxPriorityFeePerGas"
    }
    
    let maxFeePerGasStr: String
    let maxPriorityFeePerGasStr: String
    
    public var maxFeePerGas: BigUInt {
        return BigUInt(hex: maxFeePerGasStr)!
    }
    
    public var maxPriorityFeePerGas: BigUInt {
        return BigUInt(hex: maxPriorityFeePerGasStr)!
    }
}
