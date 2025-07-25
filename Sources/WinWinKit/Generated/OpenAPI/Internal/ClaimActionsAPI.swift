//
// ClaimActionsAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal class ClaimActionsAPI {

    /**
     Claim Code
     
     - parameter appUserId: (path) The app user id of the user to claim the code for. 
     - parameter xApiKey: (header) The API key to authenticate with. 
     - parameter userClaimCodeRequest: (body)  
     - returns: UserClaimCodeDataResponse
     */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal class func claimCode(appUserId: String, xApiKey: String, userClaimCodeRequest: UserClaimCodeRequest) async throws -> UserClaimCodeDataResponse {
        return try await claimCodeWithRequestBuilder(appUserId: appUserId, xApiKey: xApiKey, userClaimCodeRequest: userClaimCodeRequest).execute().body
    }

    /**
     Claim Code
     - POST /users/{app_user_id}/claim-code
     - Claims a code for a user. Code can be affiliate, promo or referral code.
     - parameter appUserId: (path) The app user id of the user to claim the code for. 
     - parameter xApiKey: (header) The API key to authenticate with. 
     - parameter userClaimCodeRequest: (body)  
     - returns: RequestBuilder<UserClaimCodeDataResponse> 
     */
    internal class func claimCodeWithRequestBuilder(appUserId: String, xApiKey: String, userClaimCodeRequest: UserClaimCodeRequest) -> RequestBuilder<UserClaimCodeDataResponse> {
        var localVariablePath = "/users/{app_user_id}/claim-code"
        let appUserIdPreEscape = "\(APIHelper.mapValueToPathItem(appUserId))"
        let appUserIdPostEscape = appUserIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        localVariablePath = localVariablePath.replacingOccurrences(of: "{app_user_id}", with: appUserIdPostEscape, options: .literal, range: nil)
        let localVariableURLString = WinWinKitAPI.basePath + localVariablePath
        let localVariableParameters = JSONEncodingHelper.encodingParameters(forEncodableObject: userClaimCodeRequest)

        let localVariableUrlComponents = URLComponents(string: localVariableURLString)

        let localVariableNillableHeaders: [String: Any?] = [
            "Content-Type": "application/json",
            "x-api-key": xApiKey.encodeToJSON(),
        ]

        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)

        let localVariableRequestBuilder: RequestBuilder<UserClaimCodeDataResponse>.Type = WinWinKitAPI.requestBuilderFactory.getBuilder()

        return localVariableRequestBuilder.init(method: "POST", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: false)
    }
}
