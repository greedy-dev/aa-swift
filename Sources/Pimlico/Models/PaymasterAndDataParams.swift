//
//  PaymasterAndDataParams.swift
//  aa-swift
//
//  Created by Denis on 8/22/24.
//

import AASwift

public struct PaymasterAndDataParams: Encodable {
    public var userOperation: UserOperationRequest
    public var entryPoint: String
    public var sponsorshipPolicyId: SponsorshipPolicyId?
    
    public init(
        userOperation: UserOperationRequest,
        entryPoint: String,
        sponsorshipPolicyId: String? = nil
    ) {
        self.userOperation = userOperation
        self.entryPoint = entryPoint
        if let sponsorshipPolicyId {
            self.sponsorshipPolicyId = SponsorshipPolicyId(sponsorshipPolicyId)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(userOperation)
        try container.encode(entryPoint)
        if let sponsorshipPolicyId {
            try container.encode(sponsorshipPolicyId)
        }
    }
}

public struct SponsorshipPolicyId: Encodable {
    public var sponsorshipPolicyId: String
    
    public init(_ sponsorshipPolicyId: String) {
        self.sponsorshipPolicyId = sponsorshipPolicyId
    }
}
