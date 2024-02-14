import web3
import Foundation
import BigInt

public func failureHandler(_ error: Error) -> EthereumClientError {
    if case let .executionError(result) = error as? JSONRPCError {
        return EthereumClientError.executionError(result.error)
    } else if case .executionError = error as? EthereumClientError, let error = error as? EthereumClientError {
        return error
    } else {
        return EthereumClientError.unexpectedReturnValue
    }
}

struct UserOpCallParams: Encodable {
    let request: UserOperationRequest
    let entryPoint: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(request)
        try container.encode(entryPoint)
    }
}

open class Erc4337RpcClient: BaseEthereumClient, Erc4337Client {
    let networkQueue: OperationQueue

    public init(url: URL, network: EthereumNetwork, headers: [String: String] = [:]) {
        let networkQueue = OperationQueue()
        networkQueue.name = "Erc4337RpcClient.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
        self.networkQueue = networkQueue
        let configuration = URLSession.shared.configuration
        configuration.httpAdditionalHeaders = headers
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: networkQueue)
        
        super.init(networkProvider: HttpNetworkProvider(session: session, url: url), url: url, logger: nil, network: network)
    }
    
    public func estimateUserOperationGas(request: UserOperationRequest, entryPoint: String) async throws -> EstimateUserOperationGasResponse {
        do {
            let data = try await networkProvider.send(method: "eth_estimateUserOperationGas", params: UserOpCallParams(request: request, entryPoint: entryPoint), receive: EstimateUserOperationGasResponse.self)
            if let result = data as? EstimateUserOperationGasResponse {
                return result
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func sendUserOperation(request: UserOperationRequest, entryPoint: String) async throws -> String {
        do {
            let data = try await networkProvider.send(method: "eth_sendUserOperation", params: UserOpCallParams(request: request, entryPoint: entryPoint), receive: String.self)
            if let result = data as? String {
                return result
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func getUserOperationReceipt(hash: String) async throws -> UserOperationReceipt {
        do {
            let data = try await networkProvider.send(method: "eth_getUserOperationReceipt", params: [hash], receive: UserOperationReceipt.self)
            if let result = data as? UserOperationReceipt {
                return result
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    open func maxPriorityFeePerGas() async throws -> BigUInt {
        do {
            let emptyParams: [Bool] = []
            let data = try await networkProvider.send(method: "eth_maxPriorityFeePerGas", params: emptyParams, receive: String.self)
            
            if let feeHex = data as? String, let fee = BigUInt(hex: feeHex) {
                return fee
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func estimateFeesPerGas(chain: Chain) async throws -> FeeValuesEIP1559 {
        guard let baseFeeMultiplier = chain.baseFeeMultiplier, baseFeeMultiplier >= 1.2 else {
            throw NSError(domain: "InvalidArguments", code: 0, userInfo: [NSLocalizedDescriptionKey: "`baseFeeMultiplier` must be greater than or equal to 1.2."])
        }

        let decimals = Decimal(baseFeeMultiplier).exponent
        let denominator = pow(10.0, Double(decimals))

        let multiply: (BigUInt) -> BigUInt = { base in
            let multiplier = BigUInt(ceil(baseFeeMultiplier * denominator))
            return (base * multiplier) / BigUInt(denominator)
        }

        let block = try await eth_getBlockByNumber(EthereumBlock.Latest)
        let maxPriorityFeePerGas = chain.defaultPriorityFee != nil ? chain.defaultPriorityFee! : try await maxPriorityFeePerGas()
        let baseFeePerGas = multiply(block.baseFeePerGas ?? BigUInt(0))
        let maxFeePerGas = baseFeePerGas + maxPriorityFeePerGas

        return FeeValuesEIP1559(
            gasPrice: baseFeePerGas,
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxPriorityFeePerGas
        )
    }
}
