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
    

    private enum CodingKeys: CodingKey {
        case userOperation
        case entryPoint
        case sponsorshipPolicyId
    }

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
}

public struct SponsorshipPolicyId: Encodable {
    public var sponsorshipPolicyId: String
    
    public init(_ sponsorshipPolicyId: String) {
        self.sponsorshipPolicyId = sponsorshipPolicyId
    }
}
