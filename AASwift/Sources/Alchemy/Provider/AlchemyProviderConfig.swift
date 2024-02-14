import AASwift

public struct AlchemyProviderConfig {
    public let chain: Chain
    public let connectionConfig: ConnectionConfig
    public let opts: SmartAccountProviderOpts?
    public let feeOpts: FeeOpts?
    
    public init(chain: Chain, connectionConfig: ConnectionConfig, opts: SmartAccountProviderOpts? = nil, feeOpts: FeeOpts? = nil) {
        self.chain = chain
        self.connectionConfig = connectionConfig
        self.opts = opts
        self.feeOpts = feeOpts
    }
}
