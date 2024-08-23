//
//  GasFees.swift
//  AA-Swift
//
//  Created by Denis on 8/21/24.
//

import BigInt
import web3
import AASwift

let pimlicoFeeEstimator: ClientMiddlewareFn = { rpcClient, operation, overrides in
    if overrides.maxFeePerGas != nil && overrides.maxPriorityFeePerGas != nil {
        operation.maxFeePerGas = overrides.maxFeePerGas
        operation.maxPriorityFeePerGas = overrides.maxPriorityFeePerGas
    } else {
        // it's a fair assumption that if someone is using this Pimlico Middleware, then they are using Pimlico RPC
        let gasFees = try await (rpcClient as! PimlicoClient).estimateUserOparationGasPrice()

        operation.maxPriorityFeePerGas = overrides.maxPriorityFeePerGas ?? gasFees.standard.maxPriorityFeePerGas
        operation.maxFeePerGas = overrides.maxFeePerGas ?? gasFees.standard.maxFeePerGas
    }
        
    return operation
}
