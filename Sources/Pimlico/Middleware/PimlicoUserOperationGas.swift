//
//  File.swift
//  AA-Swift
//
//  Created by Denis on 8/21/24.
//

import Foundation

public struct PimlicoUserOperationGas: Codable {
    let preVerificationGas: String
    let verificationGas: String
    let verificationGasLimit: String
    let callGasLimit: String
}
