public enum AlchemyError: Error {
    case unsupportedChain(String)
    case rpcUrlNotFound(String)
    case noFactoryAddress(String)
}
