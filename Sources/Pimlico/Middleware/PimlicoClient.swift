//
//  File.swift
//  AA-Swift
//
//  Created by Denis on 8/21/24.
//

import AASwift
import BigInt

public protocol PimlicoClient: Erc4337Client {
    func maxPriorityFeePerGas() async throws -> BigUInt
    func estimateUserOparationGasPrice() async throws -> PimlicoUserOperationGasPrice
    func requestGasAndPaymasterAndData(params: PaymasterAndDataParams) async throws -> PimlicoGasAndPaymasterAndData
}
