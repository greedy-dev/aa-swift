//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import Foundation

public enum PimlicoError: Error {
    case unsupportedChain(String)
    case rpcUrlNotFound(String)
    case noFactoryAddress(String)
}
