import AASwift
import BigInt

public protocol AlchemyClient: Erc4337Client {
    func maxPriorityFeePerGas() async throws -> BigUInt
    func requestPaymasterAndData(params: PaymasterAndDataParams) async throws -> AlchemyPaymasterAndData
    func requestGasAndPaymasterAndData(params: PaymasterAndDataParams) async throws -> AlchemyGasAndPaymasterAndData
}
