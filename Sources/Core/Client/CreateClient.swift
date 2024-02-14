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
