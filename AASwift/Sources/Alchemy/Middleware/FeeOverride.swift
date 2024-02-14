public struct FeeOverride: Encodable {
    public let maxFeePerGas: String?
    public let maxPriorityFeePerGas: String?
    public let callGasLimit: String?
    public let verificationGasLimit: String?
    public let preVerificationGas: String?
    
    init(maxFeePerGas: String? = nil, maxPriorityFeePerGas: String? = nil, callGasLimit: String? = nil, verificationGasLimit: String? = nil, preVerificationGas: String? = nil) {
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.callGasLimit = callGasLimit
        self.verificationGasLimit = verificationGasLimit
        self.preVerificationGas = preVerificationGas
    }
}
