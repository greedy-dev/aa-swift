# AA-Swift

### Implementation of [ERC-4337: Account Abstraction](https://eips.ethereum.org/EIPS/eip-4337) in Swift

For a high-level overview, read [this blog post](https://crewapp.xyz/posts/account-abstraction-mobile/).  
For Kotlin library, [see this](https://github.com/Syn-McJ/aa-kotlin).

## Installation

### Swift Package Manager

In Package.swift:  
```
dependencies: [
    .package(url: "https://github.com/syn-mcj/aa-swift.git", .upToNextMajor(from: "0.1.1"))
]
```

In Xcode:
- Navigate to Project -> Package Dependencies -> Add.
- Enter `https://github.com/syn-mcj/aa-kotlin.git` in the Search bar.
- Add package.

## Getting started

Check the Example app for the full code.  

Send User Operation with Alchemy provider:

```
let provider = try AlchemyProvider(
    ...
).withAlchemyGasManager(
    config: ...
)

let account = try LightSmartContractAccount(...)
provider.connect(account: account)

let encodedFn = ABIFunctionEncoder("mint") // contract function name
try await encodedFn.encode(provider.getAddress()) // function parameters
        
try await provider.sendUserOperation(
    data: UserOperationCallData(
        target: contractAddress,
        data: encodedFn.encoded()
    )
)
```


## Contributing
Contributions are welcome. Just open a well-structured issue or a PR.
