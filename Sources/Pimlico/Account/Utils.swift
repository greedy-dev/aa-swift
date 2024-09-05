//
//  Utils.swift
//  AA-Swift
//
//  Created by Denis on 8/23/24.
//

import AASwift
import web3

extension Chain {
    public func getDefaultKernelAccountFactoryAddress() throws -> EthereumAddress {
        switch self.id {
        case
            Chain.MainNet.id,
            Chain.LineaMainnet.id,
            Chain.Polygon.id: EthereumAddress("")
            
        default: throw PimlicoError.noFactoryAddress("no default kernel account factory contract exists for \(name)")
        }
    }
}
