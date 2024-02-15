//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

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
