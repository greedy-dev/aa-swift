import Foundation
import BigInt
import web3

public typealias AccountMiddlewareFn = (inout UserOperationStruct) async throws -> UserOperationStruct

// Based on https://github.com/alchemyplatform/aa-sdk/blob/main/packages/core/src/provider/types.ts#L95
public protocol ISmartAccountProvider {
    // Boolean flag indicating if the account is connected
    var isConnected: Bool { get }

    // Returns the address of the connected account
    func getAddress() async throws -> EthereumAddress

    // Sends a user operation using the connected account.
    // - Parameter data: UserOperationCallData
    // - Returns: SendUserOperationResult containing the hash and request
    func sendUserOperation(data: UserOperationCallData) async throws -> String

    // Allows you to get the unsigned UserOperation struct with all of the middleware run on it
    // - Parameter data: UserOperationCallData
    // - Returns: UserOperationStruct resulting from the middleware pipeline
    func buildUserOperation(data: UserOperationCallData) async throws -> UserOperationStruct

    // Waits for the user operation to be included in a transaction that's been mined.
    // - Parameter hash: The user operation hash you want to wait for
    // - Returns: The receipt of the user operation
    @discardableResult
    func waitForUserOperationTransaction(hash: String) async throws -> UserOperationReceipt

    // Middleware Overriders
    // Overrides the feeDataGetter middleware for setting the fee fields on the UserOperation
    @discardableResult
    func withFeeDataGetter(feeDataGetter: @escaping AccountMiddlewareFn) -> ISmartAccountProvider

    // Overrides the gasEstimator middleware for setting the gasLimit fields on the UserOperation
    @discardableResult
    func withGasEstimator(gasEstimator: @escaping AccountMiddlewareFn) -> ISmartAccountProvider

    // Overrides the default dummy paymaster data middleware and get paymaster and data middleware
    @discardableResult
    func withPaymasterMiddleware(
        dummyPaymasterDataMiddleware: AccountMiddlewareFn?,
        paymasterDataMiddleware: AccountMiddlewareFn?
    ) -> ISmartAccountProvider
}
