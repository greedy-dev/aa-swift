//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import AASwift
import Foundation
import web3
import BigInt

public func createAlchemyClient(
    url: String,
    chain: Chain,
    headers: [String: String] = [:]
) -> AlchemyClient {
    return AlchemyRpcClient(url: URL(string: url)!, network: EthereumNetwork.custom(String(describing: chain.id)), headers: headers)
}
