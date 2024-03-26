//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import BigInt
import web3
import AASwift

let alchemyFeeEstimator: ClientMiddlewareFn = { rpcClient, operation, overrides in
    if overrides.maxFeePerGas != nil && overrides.maxPriorityFeePerGas != nil {
        operation.maxFeePerGas = overrides.maxFeePerGas
        operation.maxPriorityFeePerGas = overrides.maxPriorityFeePerGas
    } else {
        let block = try await rpcClient.eth_getBlockFeeInfoByNumber(EthereumBlock.Latest)
        let baseFeePerGas = block.baseFeePerGas ?? BigUInt(0)
        let maxPriorityFeePerGasEstimate =
            // it's a fair assumption that if someone is using this Alchemy Middleware, then they are using Alchemy RPC
            try await (rpcClient as! AlchemyClient).maxPriorityFeePerGas()

        let maxPriorityFeePerGas = overrides.maxPriorityFeePerGas ?? maxPriorityFeePerGasEstimate
        operation.maxPriorityFeePerGas = maxPriorityFeePerGas
        operation.maxFeePerGas = baseFeePerGas + maxPriorityFeePerGas
    }
        
    return operation
}
