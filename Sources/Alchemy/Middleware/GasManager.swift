//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import BigInt
import AASwift

public struct AlchemyGasManagerConfig {
    public let policyId: String
    
    public init(policyId: String) {
        self.policyId = policyId
    }
}

extension AlchemyProvider {
    @discardableResult
    public func withAlchemyGasManager(config: AlchemyGasManagerConfig, estimateGas: Bool = true) -> Self {
        if estimateGas {
            withGasEstimator { operation in
                var uoStruct = operation
                uoStruct.callGasLimit = BigUInt(0)
                uoStruct.preVerificationGas = BigUInt(0)
                uoStruct.verificationGasLimit = BigUInt(0)
                return uoStruct
            }
            
            withFeeDataGetter { operation in
                var uoStruct = operation
                uoStruct.maxFeePerGas = uoStruct.maxFeePerGas ?? BigUInt(0)
                uoStruct.maxPriorityFeePerGas = uoStruct.maxPriorityFeePerGas ?? BigUInt(0)
                return uoStruct
            }
            
            let middlewarePair = withAlchemyGasAndPaymasterAndDataMiddleware(provider: self, config: config)
            withPaymasterMiddleware(dummyPaymasterDataMiddleware: middlewarePair.0, paymasterDataMiddleware: middlewarePair.1)
        } else {
            let middlewarePair = withAlchemyPaymasterAndDataMiddleware(provider: self, config: config)
            withPaymasterMiddleware(dummyPaymasterDataMiddleware: middlewarePair.0, paymasterDataMiddleware: middlewarePair.1)
        }
        
        return self
    }
}

func withAlchemyPaymasterAndDataMiddleware(provider: AlchemyProvider, config: AlchemyGasManagerConfig) -> (AccountMiddlewareFn?, AccountMiddlewareFn?) {
    let dummyPaymasterDataMiddleware: AccountMiddlewareFn = { operation in
        var uoStruct = operation
        uoStruct.paymasterAndData = (provider.chain.id == Chain.MainNet.id || provider.chain.id == Chain.Optimism.id || provider.chain.id == Chain.Polygon.id || provider.chain.id == Chain.Arbitrum.id)
            ? "0x4Fd9098af9ddcB41DA48A1d78F91F1398965addcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c"
            : "0xc03aac639bb21233e0139381970328db8bceeb67fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c"
        uoStruct.paymasterAndData = uoStruct.paymasterAndData
        
        return uoStruct
    }

    let paymasterDataMiddleware: AccountMiddlewareFn = { operation in
        var uoStruct = operation
        let entryPoint = try provider.getEntryPointAddress()
        let params = PaymasterAndDataParams(
            policyId: config.policyId,
            entryPoint: entryPoint.asString(),
            userOperation: uoStruct.toUserOperationRequest()
        )
        
        let alchemyClient = provider.rpcClient as! AlchemyClient
        uoStruct.paymasterAndData = try await alchemyClient.requestPaymasterAndData(params: params).paymasterAndData
        
        return uoStruct
    }

    return (dummyPaymasterDataMiddleware, paymasterDataMiddleware)
}

func withAlchemyGasAndPaymasterAndDataMiddleware(provider: AlchemyProvider, config: AlchemyGasManagerConfig) -> (AccountMiddlewareFn?, AccountMiddlewareFn?) {
    let paymasterDataMiddleware: AccountMiddlewareFn = { operation in
        var uoStruct = operation
        let userOperation = uoStruct.toUserOperationRequest()
        var feeOverride: FeeOverride? = nil

        if (uoStruct.maxFeePerGas ?? BigUInt(0)) > BigUInt(0) {
            feeOverride = FeeOverride(
                maxFeePerGas: userOperation.maxFeePerGas,
                maxPriorityFeePerGas: userOperation.maxPriorityFeePerGas
            )
        }

        if let alchemyClient = provider.rpcClient as? AlchemyClient {
            let result = try await alchemyClient.requestGasAndPaymasterAndData(
                params: PaymasterAndDataParams(
                    policyId: config.policyId,
                    entryPoint: provider.getEntryPointAddress().asString(),
                    userOperation: userOperation,
                    dummySignature: userOperation.signature,
                    feeOverride: feeOverride
                )
            )

            uoStruct.paymasterAndData = result.paymasterAndData
            uoStruct.callGasLimit = result.callGasLimit
            uoStruct.verificationGasLimit = result.verificationGasLimit
            uoStruct.preVerificationGas = result.preVerificationGas
            uoStruct.maxFeePerGas = result.maxFeePerGas
            uoStruct.maxPriorityFeePerGas = result.maxPriorityFeePerGas
        }
        
        return uoStruct
    }

    return (nil, paymasterDataMiddleware)
}
