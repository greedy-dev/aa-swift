//
//  GasManager.swift
//  AA-Swift
//
//  Created by Denis on 8/22/24.
//

import Foundation
import BigInt
import AASwift

public struct PimlicoGasManagerConfig {
    public let policyId: String?
    
    public init(policyId: String? = nil) {
        self.policyId = policyId
    }
}

public struct PimicoGasEstimationOptions {
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

extension PimlicoProvider {
    /// This middleware wraps the Pimlico paymaster APIs to provide more flexible UserOperation gas sponsorship.
    ///
    /// - parameters:
    ///   - config - the pimlico gas manager configuration
    ///   - gasEstimationOptions - options to customize gas estimation middleware
    /// - returns: the provider augmented to use the pimlico gas manager
    @discardableResult
    public func withPimlicoGasManager(
        config: PimlicoGasManagerConfig = PimlicoGasManagerConfig(),
        gasEstimationOptions: PimicoGasEstimationOptions? = nil
    ) -> Self {
        let fallbackFeeDataGetter = gasEstimationOptions?.fallbackFeeDataGetter ?? pimlicoFeeEstimator
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

/// - parameter provider: the smart account provider to override to use the paymaster middleware
/// - parameter config: the alchemy gas manager configuration
/// - returns: the provider augmented to use the paymaster middleware
func requestPaymasterAndData(
    provider: PimlicoProvider,
    config: PimlicoGasManagerConfig
) -> PimlicoProvider {
    provider.withPaymasterMiddleware(
        dummyPaymasterDataMiddleware: { _, uoStruct, _ in
            uoStruct.paymasterAndData = dummyPaymasterAndData(chainId: provider.chain.id)
            return uoStruct
        },
        paymasterDataMiddleware: { _, uoStruct, _ in
            let entryPoint = try provider.getEntryPointAddress()
            let params = PaymasterAndDataParams(
                userOperation: uoStruct.toUserOperationRequest(),
                entryPoint: entryPoint.asString(),
                sponsorshipPolicyId: config.policyId
            )
            let pimlicoClient = provider.rpcClient as! PimlicoClient
            uoStruct.paymasterAndData = try await pimlicoClient.requestGasAndPaymasterAndData(params: params).paymasterAndData
            return uoStruct
        }
    )
    return provider
}


/// This uses the alchemy RPC method to get all of the gas estimates + paymaster data
/// in one RPC call. It will no-op the gas estimator and fee data getter middleware and set a custom middleware that makes the RPC call.
///
/// - Parameters:
///   - provider: the smart account provider to override to use the paymaster middleware
///   - config: the alchemy gas manager configuration
/// - Returns: the provider augmented to use the paymaster middleware
func requestGasAndPaymasterData(
    provider: PimlicoProvider,
    config: PimlicoGasManagerConfig
) -> PimlicoProvider {
    provider
        .withPaymasterMiddleware(
        dummyPaymasterDataMiddleware: { _, uoStruct, _ in
            uoStruct.paymasterAndData = dummyPaymasterAndData(chainId: provider.chain.id)
            return uoStruct
        },
        paymasterDataMiddleware: { _, uoStruct, _ in
            let userOperation = uoStruct.toUserOperationRequest()

            if let pimlicoClient = provider.rpcClient as? PimlicoClient {
                let result = try await pimlicoClient.requestGasAndPaymasterAndData(
                    params: PaymasterAndDataParams(
                        userOperation: userOperation,
                        entryPoint: provider.getEntryPointAddress().asString(),
                        sponsorshipPolicyId: config.policyId
                    )
                )

                uoStruct.paymasterAndData = result.paymasterAndData
                uoStruct.callGasLimit = result.callGasLimit
                uoStruct.verificationGasLimit = result.verificationGasLimit
                uoStruct.preVerificationGas = result.preVerificationGas
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
