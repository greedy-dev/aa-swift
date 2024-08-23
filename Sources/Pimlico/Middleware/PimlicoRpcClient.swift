//
//  PimlicoRpcClient.swift
//  AA-Swift
//
//  Created by Denis on 8/21/24.
//

import AASwift
import Foundation
import BigInt
import web3

class PimlicoRpcClient: Erc4337RpcClient, PimlicoClient {
    override func maxPriorityFeePerGas() async throws -> BigUInt {
        do {
            let emptyParams: [Bool] = []
            let data = try await networkProvider.send(
                method: "pimlico_getUserOperationGasPrice",
                params: emptyParams,
                receive: PimlicoUserOperationGasPrice.self
            )
            
            if let data = data as? PimlicoUserOperationGasPrice {
                return data.standard.maxPriorityFeePerGas
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func estimateUserOparationGasPrice() async throws -> PimlicoUserOperationGasPrice {
        do {
            let emptyParams: [Bool] = []
            let data = try await networkProvider.send(
                method: "pimlico_getUserOperationGasPrice",
                params: emptyParams,
                receive: PimlicoUserOperationGasPrice.self
            )
            
            if let data = data as? PimlicoUserOperationGasPrice {
                return data
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    
    public func requestGasAndPaymasterAndData(params: PaymasterAndDataParams) async throws -> PimlicoGasAndPaymasterAndData {
        do {
            let data = try await networkProvider.send(method: "pm_sponsorUserOperation", params: [params], receive: PimlicoGasAndPaymasterAndData.self)
            if let result = data as? PimlicoGasAndPaymasterAndData {
                return result
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
}
