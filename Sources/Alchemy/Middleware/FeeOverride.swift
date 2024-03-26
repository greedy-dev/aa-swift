//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

public struct FeeOverride: Encodable {
    public let maxFeePerGas: String?
    public let maxPriorityFeePerGas: String?
    public let callGasLimit: String?
    public let verificationGasLimit: String?
    public let preVerificationGas: String?

    public var isEmpty: Bool {
        maxFeePerGas == nil &&
        maxPriorityFeePerGas == nil &&
        callGasLimit == nil &&
        verificationGasLimit == nil &&
        preVerificationGas == nil
    }
    
    init(maxFeePerGas: String? = nil, maxPriorityFeePerGas: String? = nil, callGasLimit: String? = nil, verificationGasLimit: String? = nil, preVerificationGas: String? = nil) {
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.callGasLimit = callGasLimit
        self.verificationGasLimit = verificationGasLimit
        self.preVerificationGas = preVerificationGas
    }
}
