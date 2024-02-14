import XCTest
import BigInt
import web3
import MockSwift
@testable import AASwift

final class BaseSmartContractAccountTest: XCTestCase  {
    @Mock private var rpcClient: EthereumRPCProtocol
    @Mock private var signer: SmartAccountSigner
    
    func test_encodeGetSenderAddress_returns_correctHex() async throws {
        let scAccount = SimpleSmartContractAccount(rpcClient: rpcClient, factoryAddress: EthereumAddress("0x000000893A26168158fbeaDD9335Be5bC96592E2"), signer: signer, chain: Chain.PolygonMumbai)
        let initCode = await scAccount.getAccountInitCode()
        let encoded = scAccount.encodeGetSenderAddress(initCode: initCode).web3.hexString
        XCTAssertEqual(
            "0x9b249f6900000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000058000000893a26168158fbeadd9335be5bc96592e25fbfb9cf00000000000000000000000029df43f75149d0552475a6f9b2ac96e28796ed0b00000000000000000000000000000000000000000000000000000000000000000000000000000000".lowercased(),
            encoded.lowercased()
        )
    }
}
