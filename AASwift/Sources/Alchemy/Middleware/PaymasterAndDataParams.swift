import AASwift

public struct PaymasterAndDataParams: Encodable {
    public var policyId: String
    public var entryPoint: String
    public var userOperation: UserOperationRequest
    public var dummySignature: String?
    public var feeOverride: FeeOverride?

    public init(policyId: String, entryPoint: String, userOperation: UserOperationRequest, dummySignature: String? = nil, feeOverride: FeeOverride? = nil) {
        self.policyId = policyId
        self.entryPoint = entryPoint
        self.userOperation = userOperation
        self.dummySignature = dummySignature
        self.feeOverride = feeOverride
    }
}
