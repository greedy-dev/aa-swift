//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import AASwift

public let SupportedChains = [
    Chain.MainNet.id: Chain.MainNet,
    Chain.Arbitrum.id: Chain.Arbitrum,
    Chain.ArbitrumSepolia.id: Chain.ArbitrumSepolia,
    Chain.Base.id: Chain.Base,
    Chain.BaseSepolia.id: Chain.BaseSepolia,
    Chain.LineaMainnet.id: Chain.LineaMainnet,
    Chain.Polygon.id: Chain.Polygon,
    Chain.Sepolia.id: Chain.Sepolia,
    Chain.Optimism.id: Chain.Optimism,
]

extension Chain {
    public var pimlicoRpcHttpUrl: String? {
        if SupportedChains.keys.contains(self.id) {
            return "https://api.pimlico.io/v2/\(self.id)/rpc"
        } else {
            return nil
        }
    }
}
