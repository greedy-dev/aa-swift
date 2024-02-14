import web3
import AASwift
import BigInt

public class LightSmartContractAccount: SimpleSmartContractAccount {
    public override init(rpcClient: EthereumRPCProtocol, entryPointAddress: EthereumAddress? = nil, factoryAddress: EthereumAddress, signer: SmartAccountSigner, chain: Chain, accountAddress: EthereumAddress? = nil, index: Int64? = nil) {
        super.init(rpcClient: rpcClient, factoryAddress: factoryAddress, signer: signer, chain: chain)
    }
    
    public override func getAccountInitCode() async -> String {
        let address = await signer.getAddress()
        let encodedFn = ABIFunctionEncoder("createAccount")
        try! encodedFn.encode(EthereumAddress(address))
        try! encodedFn.encode(BigUInt(0)) // light account does not support sub-accounts
        
        return concatHex(values: [
            factoryAddress.asString(),
            try! encodedFn.encoded().web3.hexString
        ])
    }
}
