//
//  CreateClient.swift
//  AA-Swift
//
//  Created by Denis on 8/21/24.
//

import AASwift
import Foundation
import web3
import BigInt

public func createPimlicoClient(
    url: String,
    chain: Chain
) -> PimlicoClient {
    return PimlicoRpcClient(
        url: URL(string: url)!,
        network: EthereumNetwork.custom(
            String(describing: chain.id)
        )
    )
}
