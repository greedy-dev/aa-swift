//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import AASwift
import web3
import BigInt
import Foundation

public class PimlicoProvider: SmartAccountProvider {
    static private var rpcUrl: String = ""

    static private func createRpcClient(config: PimlicoProviderConfig) throws -> Erc4337Client {
        guard let chain = SupportedChains[config.chain.id] else {
            throw PimlicoError.unsupportedChain("Unsupported chain id: \(config.chain.id)")
        }

        guard let rpcUrl = chain.pimlicoRpcHttpUrl.map({ "\($0)?apikey=\(config.apiKey)" }) else {
            throw PimlicoError.rpcUrlNotFound("No rpcUrl found for chain \(config.chain.id)")
        }

        let rpcClient = createPimlicoClient(url: rpcUrl, chain: config.chain)
        self.rpcUrl = rpcUrl

        return rpcClient
    }

    public init(
        entryPointAddress: EthereumAddress?,
        config: PimlicoProviderConfig
    ) throws {
        let rpcClient = try PimlicoProvider.createRpcClient(config: config)
        try super.init(client: rpcClient, rpcUrl: nil, entryPointAddress: entryPointAddress, chain: config.chain, opts: config.opts)
        withGasEstimator(gasEstimator: pimlicoFeeEstimator)
    }

    public override func defaultGasEstimator(
        client: Erc4337Client,
        operation: inout UserOperationStruct,
        overrides: UserOperationOverrides
    ) async throws -> UserOperationStruct {
        if (overrides.preVerificationGas != nil &&
            overrides.verificationGasLimit != nil &&
            overrides.callGasLimit != nil
        ) {
            operation.preVerificationGas = overrides.preVerificationGas
            operation.verificationGasLimit = overrides.verificationGasLimit
            operation.callGasLimit = overrides.callGasLimit
        } else {
            let request = operation.toUserOperationRequest()
            let estimates = try await rpcClient.estimateUserOperationGas(request: request, entryPoint: getEntryPointAddress().asString())
            
            operation.preVerificationGas = overrides.preVerificationGas ?? estimates.preVerificationGas
            operation.verificationGasLimit = overrides.verificationGasLimit ?? estimates.verificationGasLimit
            operation.callGasLimit = overrides.callGasLimit ?? estimates.callGasLimit
        }

        return operation
    }
}
