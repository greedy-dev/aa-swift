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

public struct AlchemyGasEstimationOptions {
    public let disableGasEstimation: Bool
    public let fallbackGasEstimator: ClientMiddlewareFn?
    public let fallbackFeeDataGetter: ClientMiddlewareFn?
    
    public init(
        disableGasEstimation: Bool = false,
        fallbackGasEstimator: ClientMiddlewareFn? = nil,
        fallbackFeeDataGetter: ClientMiddlewareFn? = nil
    ) {
        self.disableGasEstimation = disableGasEstimation
        self.fallbackGasEstimator = fallbackGasEstimator
        self.fallbackFeeDataGetter = fallbackFeeDataGetter
    }
}

extension AlchemyProvider {
    /// This middleware wraps the Alchemy Gas Manager APIs to provide more flexible UserOperation gas sponsorship.
    ///
    /// If `estimateGas` is true, it will use `alchemy_requestGasAndPaymasterAndData` to get all of the gas estimates + paymaster data
    /// in one RPC call.
    ///
    /// Otherwise, it will use `alchemy_requestPaymasterAndData` to get only paymaster data, allowing you
    /// to customize the gas and fee estimation middleware.
    ///
    /// @param self - the smart account provider to override to use the alchemy gas manager
    /// @param config - the alchemy gas manager configuration
    /// @param gasEstimationOptions - options to customize gas estimation middleware
    /// @returns the provider augmented to use the alchemy gas manager
    @discardableResult
    public func withAlchemyGasManager(
        config: AlchemyGasManagerConfig, 
        gasEstimationOptions: AlchemyGasEstimationOptions? = nil
    ) -> Self {
        let fallbackFeeDataGetter = gasEstimationOptions?.fallbackFeeDataGetter ?? alchemyFeeEstimator
        let fallbackGasEstimator = gasEstimationOptions?.fallbackGasEstimator ?? defaultGasEstimator
        let disableGasEstimation = gasEstimationOptions?.disableGasEstimation ?? false

        let gasEstimator: ClientMiddlewareFn = if disableGasEstimation {
            fallbackGasEstimator
        } else {
            { client, uoStruct, overrides in
                uoStruct.callGasLimit = BigUInt(0)
                uoStruct.preVerificationGas = BigUInt(0)
                uoStruct.verificationGasLimit = BigUInt(0)

                if overrides.paymasterAndData?.isEmpty == false {
                    return try await fallbackGasEstimator(client, &uoStruct, overrides)
                } else {
                    return uoStruct
                }
            }
        }
        withGasEstimator(gasEstimator: gasEstimator)

        let feeDataGetter: ClientMiddlewareFn = if disableGasEstimation {
            fallbackFeeDataGetter
        } else {
            { client, uoStruct, overrides in
                var newMaxFeePerGas = uoStruct.maxFeePerGas ?? BigUInt(0)
                var newMaxPriorityFeePerGas = uoStruct.maxPriorityFeePerGas ?? BigUInt(0)

                // but if user is bypassing paymaster to fallback to having the account to pay the gas (one-off override),
                // we cannot delegate gas estimation to the bundler because paymaster middleware will not be called
                if overrides.paymasterAndData == nil || overrides.paymasterAndData!.isEmpty {
                    let result = try await fallbackFeeDataGetter(client, &uoStruct, overrides)
                    newMaxFeePerGas = result.maxFeePerGas ?? newMaxFeePerGas
                    newMaxPriorityFeePerGas = result.maxPriorityFeePerGas ?? newMaxPriorityFeePerGas
                }

                uoStruct.maxFeePerGas = newMaxFeePerGas
                uoStruct.maxPriorityFeePerGas = newMaxPriorityFeePerGas
                return uoStruct
            }
        }
        withFeeDataGetter(feeDataGetter: feeDataGetter)

        if disableGasEstimation {
            return requestPaymasterAndData(provider: self, config: config) as! Self
        } else {
            return requestGasAndPaymasterData(provider: self, config: config) as! Self
        }
    }
}

/// This uses the alchemy RPC method: `alchemy_requestPaymasterAndData`, which does not estimate gas. It's recommended to use
/// this middleware if you want more customization over the gas and fee estimation middleware, including setting
/// non-default buffer values for the fee/gas estimation.
///
/// - parameter provider: the smart account provider to override to use the paymaster middleware
/// - parameter config: the alchemy gas manager configuration
/// - returns: the provider augmented to use the paymaster middleware
func requestPaymasterAndData(provider: AlchemyProvider, config: AlchemyGasManagerConfig) -> AlchemyProvider {
    provider.withPaymasterMiddleware(
        dummyPaymasterDataMiddleware: { _, uoStruct, _ in
            uoStruct.paymasterAndData = dummyPaymasterAndData(chainId: provider.chain.id)
            return uoStruct
        },
        paymasterDataMiddleware: { _, uoStruct, _ in
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
    )
    return provider
}


/// This uses the alchemy RPC method: `alchemy_requestGasAndPaymasterAndData` to get all of the gas estimates + paymaster data
/// in one RPC call. It will no-op the gas estimator and fee data getter middleware and set a custom middleware that makes the RPC call.
///
/// @param provider - the smart account provider to override to use the paymaster middleware
/// @param config - the alchemy gas manager configuration
/// @returns the provider augmented to use the paymaster middleware
func requestGasAndPaymasterData(provider: AlchemyProvider, config: AlchemyGasManagerConfig) -> AlchemyProvider {
    provider.withPaymasterMiddleware(
        dummyPaymasterDataMiddleware: { _, uoStruct, _ in
            uoStruct.paymasterAndData = dummyPaymasterAndData(chainId: provider.chain.id)
            return uoStruct
        },
        paymasterDataMiddleware: { _, uoStruct, overrides in
            let userOperation = uoStruct.toUserOperationRequest()
            let feeOverride = FeeOverride(
                maxFeePerGas: overrides.maxFeePerGas?.web3.hexString,
                maxPriorityFeePerGas: overrides.maxPriorityFeePerGas?.web3.hexString,
                callGasLimit: overrides.callGasLimit?.web3.hexString,
                verificationGasLimit: overrides.verificationGasLimit?.web3.hexString,
                preVerificationGas: overrides.preVerificationGas?.web3.hexString
            )

            if let alchemyClient = provider.rpcClient as? AlchemyClient {
                let feeOverride: FeeOverride? = if feeOverride.isEmpty { nil } else { feeOverride }
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
    )
    return provider
}

private func dummyPaymasterAndData(chainId: Int64) -> String {
    switch chainId {
    case Chain.MainNet.id,
        Chain.Optimism.id,
        Chain.Polygon.id,
        Chain.Arbitrum.id: "0x4Fd9098af9ddcB41DA48A1d78F91F1398965addcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c"
        
    default: "0xc03aac639bb21233e0139381970328db8bceeb67fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c"
    }
}
