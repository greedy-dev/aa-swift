//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

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
