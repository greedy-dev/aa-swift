//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import Foundation

public struct SmartAccountProviderOpts {
    /// The maximum number of times to try fetching a transaction receipt before giving up (default: 5)
    public let txMaxRetries: Int?
    /// The interval in milliseconds to wait between retries while waiting for tx receipts (default: 2_000)
    public let txRetryIntervalMs: Int64?
    /// The multiplier on interval length to wait between retries while waiting for tx receipts (default: 1.5)
    public let txRetryMultiplier: Double?
    /// Used when computing the fees for a user operation (default: 100_000_000)
    public let minPriorityFeePerBid: Int64?
    /// Percent value for maxPriorityFeePerGas estimate added buffer. maxPriorityFeePerGasBid is set to the max
    /// between the buffer "added" priority fee estimate and the minPriorityFeePerBid (default: 33)
    public let maxPriorityFeePerGasEstimateBuffer: Int64?

    public init(txMaxRetries: Int? = nil,
         txRetryIntervalMs: Int64? = nil,
         txRetryMultiplier: Double? = nil,
         minPriorityFeePerBid: Int64? = nil,
         maxPriorityFeePerGasEstimateBuffer: Int64? = nil) {
        self.txMaxRetries = txMaxRetries
        self.txRetryIntervalMs = txRetryIntervalMs
        self.txRetryMultiplier = txRetryMultiplier
        self.minPriorityFeePerBid = minPriorityFeePerBid
        self.maxPriorityFeePerGasEstimateBuffer = maxPriorityFeePerGasEstimateBuffer
    }
}
