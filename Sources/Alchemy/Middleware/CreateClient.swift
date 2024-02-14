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
