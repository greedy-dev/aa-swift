//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import BigInt
import web3

public struct SendUserOperationResult {
    public let hash: String
    public let request: UserOperationRequest
}

public struct UserOperationOverrides {
    public let callGasLimit: BigUInt?
    public let maxFeePerGas: BigUInt?
    public let maxPriorityFeePerGas: BigUInt?
    public let preVerificationGas: BigUInt?
    public let verificationGasLimit: BigUInt?
    public let paymasterAndData: String?
    
    public init(callGasLimit: BigUInt? = nil, maxFeePerGas: BigUInt? = nil, maxPriorityFeePerGas: BigUInt? = nil, preVerificationGas: BigUInt? = nil, verificationGasLimit: BigUInt? = nil, paymasterAndData: String? = nil) {
        self.callGasLimit = callGasLimit
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.preVerificationGas = preVerificationGas
        self.verificationGasLimit = verificationGasLimit
        self.paymasterAndData = paymasterAndData
    }
}

public struct UserOperationCallData: Equatable  {
    /// the target of the call
    public let target: EthereumAddress
    /// the data passed to the target
    public let data: Data
    /// the amount of native token to send to the target (default: 0)
    public let value: BigUInt?
    
    public init(target: EthereumAddress, data: Data, value: BigUInt? = nil) {
        self.target = target
        self.data = data
        self.value = value
    }
}

extension UserOperationCallData: ABITuple {
    public init?(values: [web3.ABIDecoder.DecodedValue]) throws {
        self.target = try values[0].decoded()
        self.value = try values[1].decoded()
        self.data = try values[2].decoded()
    }
    
    public static var rawType: web3.ABIRawType {
        .Tuple([.FixedAddress, .FixedUInt(256), .DynamicBytes])
    }
    
    
    
    public static var types: [any web3.ABIType.Type] {
        [EthereumAddress.self, BigUInt.self, Data.self]
    }
    
    public var encodableValues: [any web3.ABIType] {
        let values: [any web3.ABIType] = [self.target, self.value ?? BigUInt(0), self.data]
        
        return values
    }
    
    public func encode(to encoder: web3.ABIFunctionEncoder) throws {
        try encoder.encode(self.target)
        try encoder.encode(self.value ?? BigUInt(0))
        try encoder.encode(self.data)
    }
}


/// Represents the request as it needs to be formatted for RPC requests
public struct UserOperationRequest: Equatable, Encodable {
    /// The origin of the request
    public let sender: String
    /// Nonce of the transaction, returned from the entrypoint for this Address
    public let nonce: String
    /// The initCode for creating the sender if it does not exist yet, otherwise "0x"
    public let initCode: String
    /// The callData passed to the target
    public let callData: String
    /// Value used by inner account execution
    public let callGasLimit: String
    /// Actual gas used by the validation of this UserOperation
    public let verificationGasLimit: String
    /// Gas overhead of this UserOperation
    public let preVerificationGas: String
    /// Maximum fee per gas (similar to EIP-1559 max_fee_per_gas)
    public let maxFeePerGas: String
    /// Maximum priority fee per gas (similar to EIP-1559 max_priority_fee_per_gas)
    public let maxPriorityFeePerGas: String
    /// Address of paymaster sponsoring the transaction, followed by extra data to send to the paymaster ("0x" for self-sponsored transaction)
    public let paymasterAndData: String
    /// Data passed into the account along with the nonce during the verification step
    public let signature: String
}

/// Based on @account-abstraction/common
/// This is used for building requests
public struct UserOperationStruct: Equatable {
    /// The origin of the request
    public var sender: String
    /// Nonce of the transaction, returned from the entrypoint for this Address
    public var nonce: BigUInt
    /// The initCode for creating the sender if it does not exist yet, otherwise "0x"
    public var initCode: String
    /// The callData passed to the target
    public var callData: String
    /// Value used by inner account execution
    public var callGasLimit: BigUInt?
    /// Actual gas used by the validation of this UserOperation
    public var verificationGasLimit: BigUInt?
    /// Gas overhead of this UserOperation
    public var preVerificationGas: BigUInt?
    /// Maximum fee per gas (similar to EIP-1559 max_fee_per_gas)
    public var maxFeePerGas: BigUInt?
    /// Maximum priority fee per gas (similar to EIP-1559 max_priority_fee_per_gas)
    public var maxPriorityFeePerGas: BigUInt?
    /// Address of paymaster sponsoring the transaction, followed by extra data to send to the paymaster ("0x" for self-sponsored transaction)
    public var paymasterAndData: String
    /// Data passed into the account along with the nonce during the verification step
    public var signature: Data
    
    public init(sender: String, nonce: BigUInt, initCode: String, callData: String, callGasLimit: BigUInt? = nil, verificationGasLimit: BigUInt? = nil, preVerificationGas: BigUInt? = nil, maxFeePerGas: BigUInt? = nil, maxPriorityFeePerGas: BigUInt? = nil, paymasterAndData: String, signature: Data) {
        self.sender = sender
        self.nonce = nonce
        self.initCode = initCode
        self.callData = callData
        self.callGasLimit = callGasLimit
        self.verificationGasLimit = verificationGasLimit
        self.preVerificationGas = preVerificationGas
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.paymasterAndData = paymasterAndData
        self.signature = signature
    }
}

public struct UserOperationReceipt: Equatable, Codable {
    enum CodingKeys: String, CodingKey {
        case userOpHash
        case entryPoint
        case sender
        case nonce
        case paymaster
        case actualGasCost
        case actualGasUsed
        case success
        case reason
        case receipt
    }
    
    /// The request hash of the UserOperation.
    let userOpHash: String
    /// The entry point address used for the UserOperation.
    let entryPoint: String
    /// The account initiating the UserOperation.
    let sender: String
    /// The nonce used in the UserOperation.
    let nonce: String
    /// The paymaster used for this UserOperation (or empty).
    let paymaster: String
    /// The actual amount paid (by account or paymaster) for this UserOperation.
    let actualGasCost: String
    /// Indicates whether the execution completed without reverting.
    let actualGasUsed: String
    /// Indicates whether the execution completed without reverting.
    let success: Bool
    /// In case of revert, this is the revert reason.
    let reason: String
    /// The TransactionReceipt object for the entire bundle, not only for this UserOperation.
    let receipt: Receipt
}

struct Receipt: Equatable, Codable {
    enum CodingKeys: String, CodingKey {
        case transactionHash
        case transactionIndex
        case blockHash
        case blockNumber
        case from
        case to
        case cumulativeGasUsed
        case gasUsed
        case contractAddress
        case status
        case logsBloom
        case type
        case effectiveGasPrice
    }
    
    ///  hash of the transaction
    let transactionHash: String
    /// The index of the transaction within the block.
    let transactionIndex: String
    /// The hash of the block where the given transaction was included.
    let blockHash: String
    /// The number of the block where the given transaction was included.
    let blockNumber: String
    /// address of the sender
    let from: String
    /// address of the receiver. null when its a contract creation transaction
    let to: String?
    /// The total amount of gas used when this transaction was executed in the block.
    let cumulativeGasUsed: String
    /// The amount of gas used by this specific transaction alone
    let gasUsed: String
    /// The contract address created, if the transaction was a contract creation, otherwise null
    let contractAddress: String?
    let status: String
    /// Bloom filter for light clients to quickly retrieve related logs
    let logsBloom: String
    let type: String
    let effectiveGasPrice: String
}
