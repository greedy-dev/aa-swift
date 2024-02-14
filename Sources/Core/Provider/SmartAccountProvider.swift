import Foundation
import BigInt
import web3

public enum SmartAccountProviderError: Error {
    case notConnected(String)
    case noRpc(String)
    case noParameters(String)
    case noTransaction(String)
}

open class SmartAccountProvider: ISmartAccountProvider {
    private static let minPriorityFeePerBidDefaults: [Int: Int64] = [
        Chain.Arbitrum.id: 10_000_000,
        Chain.ArbitrumGoerli.id: 10_000_000,
        Chain.ArbitrumSepolia.id: 10_000_000
    ]

    public let rpcClient: Erc4337Client!
    public let chain: Chain!
    let entryPointAddress: EthereumAddress!
    let opts: SmartAccountProviderOpts!

    private var account: ISmartContractAccount?
    private var gasEstimator: AccountMiddlewareFn!
    private var feeDataGetter: AccountMiddlewareFn!
    private var paymasterDataMiddleware: AccountMiddlewareFn!
    private var dummyPaymasterDataMiddleware: AccountMiddlewareFn!

    private let minPriorityFeePerBid: BigUInt

    public var isConnected: Bool {
        return self.account != nil
    }

    public init(client: Erc4337Client?, rpcUrl: String?, entryPointAddress: EthereumAddress?, chain: Chain, opts: SmartAccountProviderOpts? = nil) throws {
        var rpcClient = client
        
        if rpcClient == nil && rpcUrl != nil {
            rpcClient = createPublicErc4337Client(rpcUrl: rpcUrl!, chain: chain)
        }

        guard let rpcClient = rpcClient else {
            throw SmartAccountProviderError.noRpc("No rpcUrl or client provided")
        }

        self.rpcClient = rpcClient
        self.chain = chain
        self.entryPointAddress = entryPointAddress
        self.opts = opts

        let defaultFee = SmartAccountProvider.minPriorityFeePerBidDefaults[chain.id] ?? 100_000_000
        self.minPriorityFeePerBid = BigUInt(opts?.minPriorityFeePerBid ?? defaultFee)
        
        self.gasEstimator = defaultGasEstimator
        self.feeDataGetter = defaultFeeDataGetter
        self.paymasterDataMiddleware = defaultPaymasterDataMiddleware
        self.dummyPaymasterDataMiddleware = defaultDummyPaymasterDataMiddleware
    }
    
    public func connect(account: ISmartContractAccount) {
        self.account = account
        // TODO: this method isn't very useful atm
    }
    
    public func getAddress() async throws -> EthereumAddress {
        guard var account = self.account else {
            throw SmartAccountProviderError.notConnected("Account not connected")
        }
        
        return try await account.getAddress()
    }
    
    public func sendUserOperation(data: UserOperationCallData) async throws -> String {
        guard self.account != nil else {
            throw SmartAccountProviderError.notConnected("Account not connected")
        }

        let uoStruct = try await self.buildUserOperation(data: data)
        return try await sendUserOperation(uoStruct: uoStruct)
    }
    
    public func buildUserOperation(data: UserOperationCallData) async throws -> UserOperationStruct {
        guard var account = self.account else {
            throw SmartAccountProviderError.notConnected("Account not connected")
        }

        let initCode = try await account.getInitCode()
        let address = try await self.getAddress()
        let nonce = try await account.getNonce()
        let callData = await account.encodeExecute(target: data.target, value: data.value ?? BigUInt(0), data: data.data)
        let signature = account.getDummySignature()

        var userOperationStruct = UserOperationStruct(
            sender: address.asString(),
            nonce: nonce,
            initCode: initCode,
            callData: callData,
            paymasterAndData: "0x",
            signature: signature
        )

        return try await self.runMiddlewareStack(uoStruct: &userOperationStruct)
    }
    
    public func waitForUserOperationTransaction(hash: String) async throws -> UserOperationReceipt {
        let txMaxRetries = opts?.txMaxRetries ?? 5
        let txRetryIntervalMs = opts?.txRetryIntervalMs ?? 2000
        let txRetryMultiplier = opts?.txRetryMultiplier ?? 1.5

        for i in 0..<txMaxRetries {
            let txRetryIntervalWithJitterMs = Double(txRetryIntervalMs) * pow(txRetryMultiplier, Double(i)) + Double.random(in: 0..<100)
            try await Task.sleep(nanoseconds: UInt64(txRetryIntervalWithJitterMs) * 1_000_000)

            do {
                return try await rpcClient.getUserOperationReceipt(hash: hash)
            } catch {
                if i == txMaxRetries - 1 {
                    throw error
                }
            }
        }

        throw SmartAccountProviderError.noTransaction("Failed to find transaction for User Operation")
    }
    
    @discardableResult
    public func withFeeDataGetter(feeDataGetter: @escaping AccountMiddlewareFn) -> ISmartAccountProvider {
        self.feeDataGetter = feeDataGetter
        return self
    }
    
    @discardableResult
    public func withGasEstimator(gasEstimator: @escaping AccountMiddlewareFn) -> ISmartAccountProvider {
        self.gasEstimator = gasEstimator
        return self
    }
    
    @discardableResult
    public func withPaymasterMiddleware(dummyPaymasterDataMiddleware: AccountMiddlewareFn?, paymasterDataMiddleware: AccountMiddlewareFn?) -> ISmartAccountProvider {
        
        if let dummyPaymasterDataMiddleware = dummyPaymasterDataMiddleware {
            self.dummyPaymasterDataMiddleware = dummyPaymasterDataMiddleware
        }
        
        if let paymasterDataMiddleware = paymasterDataMiddleware {
            self.paymasterDataMiddleware = paymasterDataMiddleware
        }
        
        return self
    }
    
    private func runMiddlewareStack(uoStruct: inout UserOperationStruct) async throws -> UserOperationStruct {
        // Reversed order - dummyPaymasterDataMiddleware is called first
        let asyncPipe = chain(paymasterDataMiddleware, with:
                        chain(gasEstimator, with:
                        chain(feeDataGetter, with:
                              dummyPaymasterDataMiddleware)))
        return try await asyncPipe(&uoStruct)
    }

    // These are dependent on the specific paymaster being used
    // You should implement your own middleware to override these
    // or extend this class and provider your own implementation
    
    open func defaultDummyPaymasterDataMiddleware(operation: inout UserOperationStruct) async throws -> UserOperationStruct {
        operation.paymasterAndData = "0x"
        return operation
    }
    
    open func defaultPaymasterDataMiddleware(operation: inout UserOperationStruct) async throws -> UserOperationStruct {
        operation.paymasterAndData = "0x"
        return operation
    }
    
    open func defaultFeeDataGetter(operation: inout UserOperationStruct) async throws -> UserOperationStruct {
        let maxPriorityFeePerGas = try await rpcClient.maxPriorityFeePerGas()
        let feeData = try await rpcClient.estimateFeesPerGas(chain: chain)

        // set maxPriorityFeePerGasBid to the max between 33% added priority fee estimate and
        // the min priority fee per gas set for the provider
        let maxPriorityFeePerGasBid = max(bigIntPercent(
            base: maxPriorityFeePerGas,
            percent: BigUInt(100 + (opts?.maxPriorityFeePerGasEstimateBuffer ?? 33))
        ), minPriorityFeePerBid)

        let maxFeePerGasBid = feeData.maxFeePerGas - feeData.maxPriorityFeePerGas + maxPriorityFeePerGasBid
        operation.maxFeePerGas = maxFeePerGasBid
        operation.maxPriorityFeePerGas = maxPriorityFeePerGasBid

        return operation
    }
    
    open func defaultGasEstimator(operation: inout UserOperationStruct) async throws -> UserOperationStruct {
        let request = operation.toUserOperationRequest()
        let estimates = try await rpcClient.estimateUserOperationGas(request: request, entryPoint: getEntryPointAddress().asString())

        operation.preVerificationGas = estimates.preVerificationGas
        operation.verificationGasLimit = estimates.verificationGasLimit
        operation.callGasLimit = estimates.callGasLimit
        
        return operation
    }

    // Note that the connected account's entryPointAddress always takes the precedence
    public func getEntryPointAddress() throws -> EthereumAddress {
        if let entryPointAddress = self.entryPointAddress {
            return entryPointAddress
        }

        if let accountEntryPointAddress = try self.account?.getEntryPointAddress() {
            return accountEntryPointAddress
        }

        return try chain.getDefaultEntryPointAddress()
    }

    private func sendUserOperation(uoStruct: UserOperationStruct) async throws -> String {
        guard let account = self.account else {
            throw SmartAccountProviderError.notConnected("Account not connected")
        }

        guard uoStruct.isValidRequest else {
            throw SmartAccountProviderError.noParameters("Request is missing parameters. All properties on UserOperationStruct must be set. struct: \(uoStruct)")
        }

        let address = try self.getEntryPointAddress()
        let userOperationHash = getUserOperationHash(request: uoStruct, entryPointAddress: address, chainId: self.chain.id)
        var uoStructFinal = uoStruct
        uoStructFinal.signature = try await account.signMessage(msg: userOperationHash)

        let request = uoStructFinal.toUserOperationRequest()
        let uoHash = try await rpcClient!.sendUserOperation(request: request, entryPoint: address.asString())
        
        return uoHash
    }
    
    private func chain<A>(_ f: @escaping (inout A) async throws -> A, with g: @escaping (inout A) async throws -> A) -> ((inout A) async throws -> A) {
        return { x in
            var result = try await g(&x)
            return try await f(&result)
        }
    }
}
