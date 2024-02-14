import Foundation
import BigInt

public struct Currency {
    let name: String
    let symbol: String
    let decimals: Int
}

public class Chain: Equatable {
    public let id: Int
    public let network: String
    public let name: String
    public let currency: Currency
    public let baseFeeMultiplier: Double?
    public let defaultPriorityFee: BigUInt?

    public init(id: Int, network: String, name: String, currency: Currency, baseFeeMultiplier: Double? = nil, defaultPriorityFee: BigUInt? = nil) {
        self.id = id
        self.network = network
        self.name = name
        self.currency = currency
        self.baseFeeMultiplier = baseFeeMultiplier
        self.defaultPriorityFee = defaultPriorityFee
    }
    
    public static func == (lhs: Chain, rhs: Chain) -> Bool {
        lhs.id == rhs.id
    }
}

extension Chain {
    public static let MainNet = Chain(id: 1, network: "homestead", name: "Ethereum", currency: Currency(name: "Ether", symbol: "ETH", decimals: 18))
    public static let Sepolia = Chain(id: 11_155_111, network: "sepolia", name: "Sepolia", currency: Currency(name: "Sepolia Ether", symbol: "SEP", decimals: 18))
    public static let Goerli = Chain(id: 5, network: "goerli", name: "Goerli", currency: Currency(name: "Goerli Ether", symbol: "ETH", decimals: 18))
    public static let Polygon = Chain(id: 137, network: "matic", name: "Polygon", currency: Currency(name: "MATIC", symbol: "MATIC", decimals: 18))
    public static let PolygonMumbai = Chain(id: 80_001, network: "maticmum", name: "Polygon Mumbai", currency: Currency(name: "MATIC", symbol: "MATIC", decimals: 18))
    public static let Optimism = Chain(id: 10, network: "optimism", name: "OP Mainnet", currency: Currency(name: "Ether", symbol: "ETH", decimals: 18))
    public static let OptimismGoerli = Chain(id: 420, network: "optimism-goerli", name: "Optimism Goerli", currency: Currency(name: "Goerli Ether", symbol: "ETH", decimals: 18))
    public static let OptimismSepolia = Chain(id: 420_69, network: "optimism-sepolia", name: "Optimism Sepolia", currency: Currency(name: "Sepolia Ether", symbol: "ETH", decimals: 18))
    public static let Arbitrum = Chain(id: 42_161, network: "arbitrum", name: "Arbitrum One", currency: Currency(name: "Ether", symbol: "ETH", decimals: 18))
    public static let ArbitrumGoerli = Chain(id: 421_613, network: "arbitrum-goerli", name: "Arbitrum Goerli", currency: Currency(name: "Goerli Ether", symbol: "ETH", decimals: 18))
    public static let ArbitrumSepolia = Chain(id: 421_614, network: "arbitrum-sepolia", name: "Arbitrum Sepolia", currency: Currency(name: "Arbitrum Sepolia Ether", symbol: "ETH", decimals: 18))
    public static let Base = Chain(id: 8453, network: "base", name: "Base", currency: Currency(name: "Ether", symbol: "ETH", decimals: 18))
    public static let BaseGoerli = Chain(id: 84531, network: "base-goerli", name: "Base Goerli", currency: Currency(name: "Goerli Ether", symbol: "ETH", decimals: 18))
    public static let BaseSepolia = Chain(id: 84532, network: "base-sepolia", name: "Base Sepolia", currency: Currency(name: "Sepolia Ether", symbol: "ETH", decimals: 18))
}
