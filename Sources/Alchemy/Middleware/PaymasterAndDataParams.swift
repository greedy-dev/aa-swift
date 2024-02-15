//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

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
