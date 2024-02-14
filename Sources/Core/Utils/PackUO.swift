import web3
import Foundation
import BigInt


/**
 * Generates a hash for a UserOperation valid from entrypoint version 0.6 onwards
 *
 * @param request - the UserOperation to get the hash for
 * @param entryPointAddress - the entry point address that will be used to execute the UserOperation
 * @param chainId - the chain on which this UserOperation will be executed
 * @returns the hash of the UserOperation
 */
func getUserOperationHash(
    request: UserOperationStruct,
    entryPointAddress: EthereumAddress,
    chainId: Int
) -> Data {
    let array = ABIEncoder.EncodedValue.container(values: [
        try! ABIEncoder.encode(Data32(data: packUo(request: request).web3.keccak256)),
        try! ABIEncoder.encode(entryPointAddress),
        try! ABIEncoder.encode(BigUInt(chainId)),
    ], isDynamic: true, size: nil)
    
    return Data(array.bytes).web3.keccak256
}

func packUo(request: UserOperationStruct) -> Data {
    let hashedInitCode = Data(hex: request.initCode)!.web3.keccak256
    let hashedCallData = Data(hex: request.callData)!.web3.keccak256
    let hashedPaymasterAndData = Data(hex: request.paymasterAndData)!.web3.keccak256
    
    let array = ABIEncoder.EncodedValue.container(values: [
        try! ABIEncoder.encode(EthereumAddress(request.sender)),
        try! ABIEncoder.encode(request.nonce),
        try! ABIEncoder.encode(Data32(data: hashedInitCode)),
        try! ABIEncoder.encode(Data32(data: hashedCallData)),
        try! ABIEncoder.encode(request.callGasLimit!),
        try! ABIEncoder.encode(request.verificationGasLimit!),
        try! ABIEncoder.encode(request.preVerificationGas!),
        try! ABIEncoder.encode(request.maxFeePerGas!),
        try! ABIEncoder.encode(request.maxPriorityFeePerGas!),
        try! ABIEncoder.encode(Data32(data: hashedPaymasterAndData)),
    ], isDynamic: true, size: nil)
    
    return Data(array.bytes)
}
