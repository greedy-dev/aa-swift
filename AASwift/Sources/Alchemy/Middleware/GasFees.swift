import BigInt
import web3

extension AlchemyProvider {
    @discardableResult
    public func withAlchemyGasFeeEstimator(baseFeeBufferPercent: BigUInt, maxPriorityFeeBufferPercent: BigUInt) -> Self {
        return self.withFeeDataGetter { structure in
            let block = try await self.rpcClient.eth_getBlockByNumber(EthereumBlock.Latest)
            let baseFeePerGas = block.baseFeePerGas ?? BigUInt(0)
            let priorityFeePerGas = try await (self.rpcClient as! AlchemyClient).maxPriorityFeePerGas()
            
            let baseFeeIncrease = (baseFeePerGas * (BigUInt(100) + baseFeeBufferPercent)) / BigUInt(100)
            let priorityFeeIncrease = (priorityFeePerGas * (BigUInt(100) + maxPriorityFeeBufferPercent)) / BigUInt(100)
            
            var uoStruct = structure
            uoStruct.maxFeePerGas = baseFeeIncrease + priorityFeeIncrease
            uoStruct.maxPriorityFeePerGas = priorityFeeIncrease
            
            return uoStruct
        } as! Self
    }
}
