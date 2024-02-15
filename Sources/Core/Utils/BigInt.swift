//
//  Copyright (c) 2024 aa-swift
//
//  This file is part of the aa-swift project: https://github.com/syn-mcj/aa-swift,
//  and is released under the MIT License: https://opensource.org/licenses/MIT
//

import BigInt

func bigIntPercent(base: BigUInt, percent: BigUInt) -> BigUInt {
    return (base * percent) / BigUInt(100)
}

func max(_ first: BigUInt, _ second: BigUInt) -> BigUInt {
    return first > second ? first : second
}
