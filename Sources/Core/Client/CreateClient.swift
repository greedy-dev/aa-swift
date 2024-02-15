//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import web3
import BigInt

public func createPublicErc4337Client(
    rpcUrl: String,
    chain: Chain,
    headers: [String: String] = [:]
) -> Erc4337Client {
    return Erc4337RpcClient(url: URL(string: rpcUrl)!, network: EthereumNetwork.custom(String(describing: chain.id)), headers: headers)
}
