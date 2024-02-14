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
