//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import AASwift
import web3
import BigInt
import Foundation

public class AlchemyProvider: SmartAccountProvider {
    static private var rpcUrl: String = ""

    static private func createRpcClient(config: AlchemyProviderConfig) throws -> Erc4337Client {
        guard let chain = SupportedChains[config.chain.id] else {
            throw AlchemyError.unsupportedChain("Unsupported chain id: \(config.chain.id)")
        }

        guard let rpcUrl = config.connectionConfig.rpcUrl ?? (chain.alchemyRpcHttpUrl.map { "\($0)/\(config.connectionConfig.apiKey ?? "")" }) else {
            throw AlchemyError.rpcUrlNotFound("No rpcUrl found for chain \(config.chain.id)")
        }

        let headers = config.connectionConfig.jwt.map {
            ["Authorization": "Bearer \($0)"]
        } ?? [:]
        let rpcClient = createAlchemyClient(url: rpcUrl, chain: config.chain, headers: headers)
        self.rpcUrl = rpcUrl

        return rpcClient
    }

    private var pvgBuffer: Int
    private var feeOptsSet: Bool

    public init(entryPointAddress: EthereumAddress?, config: AlchemyProviderConfig) throws {
        let rpcClient = try AlchemyProvider.createRpcClient(config: config)
        self.pvgBuffer = config.feeOpts?.preVerificationGasBufferPercent ??
                         ([
                            Chain.Arbitrum.id,
                            Chain.ArbitrumGoerli.id,
                            Chain.Optimism.id,
                            Chain.OptimismGoerli.id
                         ].contains(config.chain.id) ? 5 : 0)
        self.feeOptsSet = config.feeOpts != nil
        
        try super.init(client: rpcClient, rpcUrl: nil, entryPointAddress: entryPointAddress, chain: config.chain, opts: config.opts)
        
        withAlchemyGasFeeEstimator(baseFeeBufferPercent: BigUInt(config.feeOpts?.baseFeeBufferPercent ?? 50), maxPriorityFeeBufferPercent: BigUInt(config.feeOpts?.maxPriorityFeeBufferPercent ?? 5))
    }

    public override func defaultGasEstimator(operation: inout UserOperationStruct) async throws -> UserOperationStruct {
        let request = operation.toUserOperationRequest()
        let estimates = try await rpcClient.estimateUserOperationGas(request: request, entryPoint: getEntryPointAddress().asString())

        operation.preVerificationGas = (estimates.preVerificationGas * BigUInt(100 + self.pvgBuffer)) / BigUInt(100)
        operation.verificationGasLimit = estimates.verificationGasLimit
        operation.callGasLimit = estimates.callGasLimit

        return operation
    }
}
