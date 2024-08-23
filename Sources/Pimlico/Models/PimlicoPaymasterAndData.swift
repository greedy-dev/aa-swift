//
//  File.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import Foundation
import web3

public struct ErrorObject: Equatable, Codable {
    public enum CodingKeys: String, CodingKey {
        case code
        case message
    }
    
    public let code: Int
    public let message: String
}

public struct PimlicoPaymasterAndData: Equatable, Codable {
    public let paymasterAndData: String
    public let error: ErrorObject?

    public enum CodingKeys: String, CodingKey {
        case paymasterAndData
        case error
    }
}
