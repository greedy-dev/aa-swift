//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import BigInt

public struct FeeValuesEIP1559: Codable {
    enum CodingKeys: String, CodingKey {
        case gasPrice = "gasPrice"
        case maxFeePerGas = "maxFeePerGas"
        case maxPriorityFeePerGas = "maxPriorityFeePerGas"
    }
    
    /// Base fee per gas.
    let gasPrice: BigUInt
    /// Total fee per gas in wei (gasPrice/baseFeePerGas + maxPriorityFeePerGas).
    let maxFeePerGas: BigUInt
    /// Max priority fee per gas (in wei).
    let maxPriorityFeePerGas: BigUInt
}
