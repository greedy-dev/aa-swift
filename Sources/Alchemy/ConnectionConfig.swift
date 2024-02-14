public struct ConnectionConfig {
    public let apiKey: String?
    public let jwt: String?
    public let rpcUrl: String?
    
    public init(apiKey: String?, jwt: String?, rpcUrl: String? = nil) {
        self.apiKey = apiKey
        self.jwt = jwt
        self.rpcUrl = rpcUrl
    }
}
