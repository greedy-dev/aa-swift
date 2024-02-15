//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import BigInt

public func concatHex(values: [String]) -> String {
    return values.map { $0.web3.noHexPrefix }.joined().web3.withHexPrefix
}

extension UserOperationStruct {
    public func toUserOperationRequest() -> UserOperationRequest {
        return UserOperationRequest(
            sender: sender,
            nonce: nonce.web3.hexString,
            initCode: initCode,
            callData: callData,
            callGasLimit: (callGasLimit ?? BigUInt(0)).web3.hexString,
            verificationGasLimit: (verificationGasLimit ?? BigUInt(0)).web3.hexString,
            preVerificationGas: (preVerificationGas ?? BigUInt(0)).web3.hexString,
            maxFeePerGas: maxFeePerGas?.web3.hexString ?? "0x",
            maxPriorityFeePerGas: maxPriorityFeePerGas?.web3.hexString ?? "0x",
            paymasterAndData: paymasterAndData,
            signature: signature.web3.hexString
        )
    }
}
