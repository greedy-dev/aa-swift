import BigInt

extension UserOperationStruct {
    var isValidRequest: Bool {
        get {
            callGasLimit?.isZero == false &&
            maxFeePerGas?.isZero == false &&
            maxPriorityFeePerGas != nil &&
            preVerificationGas?.isZero == false &&
            verificationGasLimit?.isZero == false
        }
    }
}
