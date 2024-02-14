//
//  File.swift
//  
//
//  Created by Andrei Ashikhmin on 29/01/2024.
//

import BigInt

func bigIntPercent(base: BigUInt, percent: BigUInt) -> BigUInt {
    return (base * percent) / BigUInt(100)
}

func max(_ first: BigUInt, _ second: BigUInt) -> BigUInt {
    return first > second ? first : second
}
