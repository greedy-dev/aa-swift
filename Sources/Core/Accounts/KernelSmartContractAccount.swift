//
//  File.swift
//  AA-Swift
//
//  Created by Denis on 8/23/24.
//

import Foundation
import web3
import BigInt

let erc6492MagicValue = "0x6492649264926492649264926492649264926492649264926492649264926492"

open class KernelSmartContractAccount: BaseSmartContractAccount {
    public let chain: Chain
    public let signer: SmartAccountSigner
    public let rpcClient: EthereumRPCProtocol
    public let entryPointAddress: EthereumAddress?
    public let factoryAddress: EthereumAddress
    public let ecdsaValidatorAddress: EthereumAddress
    public let logicAddress: EthereumAddress

    public var deploymentState: DeploymentState
    public var accountAddress: EthereumAddress?
    
    private let index: Int64?
    
    public init(
        rpcClient: EthereumRPCProtocol,
        entryPointAddress: EthereumAddress? = nil,
        factoryAddress: EthereumAddress,
        ecdsaValidatorAddress: EthereumAddress,
        logicAddress: EthereumAddress,
        signer: SmartAccountSigner,
        chain: Chain,
        accountAddress: EthereumAddress? = nil,
        index: Int64? = nil
    ) {
        self.rpcClient = rpcClient
        self.signer = signer
        self.entryPointAddress = entryPointAddress
        self.factoryAddress = factoryAddress
        self.ecdsaValidatorAddress = ecdsaValidatorAddress
        self.logicAddress = logicAddress
        
        self.chain = chain
        self.accountAddress = accountAddress
        self.index = index
        self.deploymentState = .notDeployed
    }
    
    open func getAccountInitCode() async -> String {
        let factoryCalldata = await getFactoryCalldata()

        return concatHex(values: [
            factoryAddress.asString(),
            factoryCalldata.web3.hexString
        ])
    }
    
    private func getFactoryCalldata() async -> Data {
        let address = await signer.getAddress()
        
        let initFn = ABIFunctionEncoder("initialize")
        try! initFn.encode(ecdsaValidatorAddress)
        try! initFn.encode(EthereumAddress(address))
        
        let initData = try! initFn.encoded()
        
        let factoryFn = ABIFunctionEncoder("createAccount")
        try! factoryFn.encode(logicAddress)
        try! factoryFn.encode(initData)
        try! factoryFn.encode(BigUInt(self.index ?? 0))
        
        let factoryCallData = try! factoryFn.encoded()
        
        return factoryCallData
    }
    
    public func getDummySignature() -> Data {
        Data(hex: "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b"
        )!
    }
    
    public func encodeExecute(target: EthereumAddress, value: BigUInt, data: Data) async -> String {
        let encodedFn = ABIFunctionEncoder("execute")
        try! encodedFn.encode(target)
        try! encodedFn.encode(value)
        try! encodedFn.encode(data)
        
        return try! encodedFn.encoded().web3.hexString
    }
    
    public func encodeBatchExecute(txs: [UserOperationCallData]) async -> String {
        let encodedFn = ABIFunctionEncoder("executeBatch")
        try! encodedFn.encode(txs)
        
        return try! encodedFn.encoded().web3.hexString
    }
    
    public func signMessage(msg: Data) async throws -> Data {
        try await signer.signMessage(msg: msg)
    }
    
    public func signMessageWith6492(msg: Data) async throws -> Data {
        let signature = try await signMessage(msg: msg)
        let factoryCalldata = await getFactoryCalldata()
        
        let encodedData = try ABIEncoder.encode([factoryAddress.asData()!, factoryCalldata, signature]).hexString
        
        return concatHex(values: [encodedData, erc6492MagicValue]).web3.hexData!
    }
    
    public func getOwner() async -> SmartAccountSigner? {
        return signer
    }
    
    public func getFactoryAddress() async -> EthereumAddress {
        return factoryAddress
    }
}
