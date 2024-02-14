import Foundation
import BigInt

public struct FeeValuesEIP1559: Codable {
    enum CodingKeys: String, CodingKey {
        case gasPrice = "gasPrice"
        case maxFeePerGas = "maxFeePerGas"
        case maxPriorityFeePerGas = "maxPriorityFeePerGas"
    }
    
    // Base fee per gas.
    let gasPrice: BigUInt
    // Total fee per gas in wei (gasPrice/baseFeePerGas + maxPriorityFeePerGas).
    let maxFeePerGas: BigUInt
    // Max priority fee per gas (in wei).
    let maxPriorityFeePerGas: BigUInt
}
