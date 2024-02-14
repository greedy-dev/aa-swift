import web3
import BigInt

public protocol Erc4337Client: EthereumRPCProtocol {
    /**
     * calls eth_estimateUserOperationGas and  returns the result
     *
     * @param request - the {@link UserOperationRequest} to estimate gas for
     * @param entryPoint - the entrypoint address the op will be sent to
     * @returns the gas estimates for the given response (see: {@link UserOperationEstimateGasResponse})
     */
    func estimateUserOperationGas(
        request: UserOperationRequest,
        entryPoint: String
    ) async throws -> EstimateUserOperationGasResponse

    /**
     * calls eth_sendUserOperation and returns the hash of the sent UserOperation
     *
     * @param request - the {@link UserOperationRequest} to send
     * @param entryPoint - the entrypoint address the op will be sent to
     * @returns the hash of the sent UserOperation
     */
    func sendUserOperation(
        request: UserOperationRequest,
        entryPoint: String
    ) async throws -> String

    /**
     * calls `eth_getUserOperationReceipt` and returns the {@link UserOperationReceipt}
     *
     * @param hash - the hash of the UserOperation to get the receipt for
     * @returns - {@link UserOperationResponse}
     */
    func getUserOperationReceipt(hash: String) async throws -> UserOperationReceipt

    /**
     * Returns an estimate for the fees per gas (in wei) for a
     * transaction to be likely included in the next block.
     * Defaults to [`chain.fees.estimateFeesPerGas`](/docs/clients/chains.html#fees-estimatefeespergas) if set.
     *
     * - Docs: https://viem.sh/docs/actions/public/estimateFeesPerGas.html
     *
     * @param client - Client to use
     * @param parameters - {@link EstimateFeesPerGasParameters}
     * @returns An estimate (in wei) for the fees per gas. {@link EstimateFeesPerGasReturnType}
     */
    func estimateFeesPerGas(chain: Chain) async throws -> FeeValuesEIP1559
    
    // Returns a fee per gas that is an estimate of how much you can pay as a priority fee, or 'tip', to get a transaction included in the current block.
    func maxPriorityFeePerGas() async throws -> BigUInt
}
