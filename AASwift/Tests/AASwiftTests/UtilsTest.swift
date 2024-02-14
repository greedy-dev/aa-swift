import XCTest
import BigInt
import web3
@testable import AASwift

final class UtilsTest: XCTestCase {
    var uoRequest: UserOperationRequest!
    var uoStruct: UserOperationStruct!
    
    override func setUp() async throws {
        uoRequest = UserOperationRequest(
            sender: "0xb856DBD4fA1A79a46D426f537455e7d3E79ab7c4",
            nonce: "0x1f",
            initCode: "0x",
            callData: "0xb61d27f6000000000000000000000000b856dbd4fa1a79a46d426f537455e7d3e79ab7c4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000",
            callGasLimit: "0x2f6c",
            verificationGasLimit: "0x0114c2",
            preVerificationGas: "0xa890",
            maxFeePerGas: "0x59682f1e",
            maxPriorityFeePerGas: "0x59682f00",
            paymasterAndData: "0x",
            signature: "0xd16f93b584fbfdc03a5ee85914a1f29aa35c44fea5144c387ee1040a3c1678252bf323b7e9c3e9b4dfd91cca841fc522f4d3160a1e803f2bf14eb5fa037aae4a1b"
        )
        
        uoStruct = UserOperationStruct(
            sender: uoRequest.sender,
            nonce: BigUInt(hex: uoRequest.nonce)!,
            initCode: uoRequest.initCode,
            callData: uoRequest.callData,
            callGasLimit: BigUInt(hex: uoRequest.callGasLimit)!,
            verificationGasLimit: BigUInt(hex: uoRequest.verificationGasLimit)!,
            preVerificationGas: BigUInt(hex: uoRequest.preVerificationGas)!,
            maxFeePerGas: BigUInt(hex: uoRequest.maxFeePerGas)!,
            maxPriorityFeePerGas: BigUInt(hex: uoRequest.maxPriorityFeePerGas)!,
            paymasterAndData: uoRequest.paymasterAndData,
            signature: Data(hex: uoRequest.signature)!
        )
    }
    
    func test_getUserOperationHash_returns_correctHash() throws {
        let entrypointAddress = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"
        let hash = getUserOperationHash(
            request: uoStruct,
            entryPointAddress: EthereumAddress(entrypointAddress),
            chainId: 80001
        ).web3.hexString

        XCTAssertEqual("0xa70d0af2ebb03a44dcd0714a8724f622e3ab876d0aa312f0ee04823285d6fb1b".lowercased(), hash.lowercased())
    }
    
    func test_toUserOperationRequest_returns_correctRequest() throws {
        let request = uoStruct.toUserOperationRequest()
        XCTAssertEqual(uoRequest, request)
    }
}
