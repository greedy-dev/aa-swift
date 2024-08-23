//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import AASwift

public struct PimlicoProviderConfig {
    public let chain: Chain
    public let apiKey: String
    public let opts: SmartAccountProviderOpts?
    
    public init(chain: Chain, connectionConfig: ConnectionConfig, opts: SmartAccountProviderOpts? = nil) {
        self.chain = chain
        self.apiKey = apiKey
        self.opts = opts
    }
}
