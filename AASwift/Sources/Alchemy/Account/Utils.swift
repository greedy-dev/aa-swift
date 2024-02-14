import web3
import AASwift

extension Chain {
    public func getDefaultLightAccountFactoryAddress() throws -> EthereumAddress {
        switch self.id {
        case Chain.MainNet.id,
             Chain.Sepolia.id,
             Chain.Goerli.id,
             Chain.Polygon.id,
             Chain.PolygonMumbai.id,
             Chain.Optimism.id,
             Chain.OptimismGoerli.id,
             Chain.Arbitrum.id,
             Chain.ArbitrumGoerli.id,
             Chain.Base.id,
             Chain.BaseGoerli.id: EthereumAddress("0x000000893A26168158fbeaDD9335Be5bC96592E2")

        default: throw AlchemyError.noFactoryAddress("no default light account factory contract exists for \(name)")
        }
    }
}
