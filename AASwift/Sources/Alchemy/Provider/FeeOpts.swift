public struct FeeOpts {
    /// This adds a percent buffer on top of the base fee estimated (default 50%)
    /// NOTE: this is only applied if the default fee estimator is used.
    public var baseFeeBufferPercent: Int?

    /// This adds a percent buffer on top of the priority fee estimated (default 5%)
    /// NOTE: this is only applied if the default fee estimator is used.
    public var maxPriorityFeeBufferPercent: Int?

    /// This adds a percent buffer on top of the preVerificationGas estimated
    ///
    /// Defaults 5% on Arbitrum and Optimism, 0% elsewhere
    ///
    /// This is only useful on Arbitrum and Optimism, where the preVerificationGas is
    /// dependent on the gas fee during the time of estimation. To improve chances of
    /// the UserOperation being mined, users can increase the preVerificationGas by
    /// a buffer. This buffer will always be charged, regardless of price at time of mine.
    ///
    /// NOTE: this is only applied if the default gas estimator is used.
    public var preVerificationGasBufferPercent: Int?

    public init(baseFeeBufferPercent: Int? = nil, maxPriorityFeeBufferPercent: Int? = nil, preVerificationGasBufferPercent: Int? = nil) {
        self.baseFeeBufferPercent = baseFeeBufferPercent
        self.maxPriorityFeeBufferPercent = maxPriorityFeeBufferPercent
        self.preVerificationGasBufferPercent = preVerificationGasBufferPercent
    }
}
