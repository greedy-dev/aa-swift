//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation
import web3

public class LocalAccountSigner: SmartAccountSigner {
    private let account: EthereumAccount
    public let signerType: String = "local"
    
    public init(account: EthereumAccount) {
        self.account = account
    }
    
    public func getAddress() async -> String {
        return account.address.asString()
    }
    
    public func signMessage(msg: Data) async throws -> Data {
        let signed = try account.signMessage(message: msg)
        return signed.web3.hexData!
    }
}
