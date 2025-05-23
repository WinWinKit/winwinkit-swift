//
// RewardsActionsAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal class RewardsActionsAPI {

    /**
     Withdraw Credits
     
     - parameter appUserId: (path) The app user id of the user to withdraw credits from. 
     - parameter xApiKey: (header) The API key to authenticate with. 
     - parameter userWithdrawCreditsRequest: (body)  
     - returns: UserWithdrawCreditsDataResponse
     */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal class func withdrawCredits(appUserId: String, xApiKey: String, userWithdrawCreditsRequest: UserWithdrawCreditsRequest) async throws -> UserWithdrawCreditsDataResponse {
        return try await withdrawCreditsWithRequestBuilder(appUserId: appUserId, xApiKey: xApiKey, userWithdrawCreditsRequest: userWithdrawCreditsRequest).execute().body
    }

    /**
     Withdraw Credits
     - POST /users/{app_user_id}/rewards/withdraw-credits
     - Withdraws credits from a user.
     - parameter appUserId: (path) The app user id of the user to withdraw credits from. 
     - parameter xApiKey: (header) The API key to authenticate with. 
     - parameter userWithdrawCreditsRequest: (body)  
     - returns: RequestBuilder<UserWithdrawCreditsDataResponse> 
     */
    internal class func withdrawCreditsWithRequestBuilder(appUserId: String, xApiKey: String, userWithdrawCreditsRequest: UserWithdrawCreditsRequest) -> RequestBuilder<UserWithdrawCreditsDataResponse> {
        var localVariablePath = "/users/{app_user_id}/rewards/withdraw-credits"
        let appUserIdPreEscape = "\(APIHelper.mapValueToPathItem(appUserId))"
        let appUserIdPostEscape = appUserIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        localVariablePath = localVariablePath.replacingOccurrences(of: "{app_user_id}", with: appUserIdPostEscape, options: .literal, range: nil)
        let localVariableURLString = WinWinKitAPI.basePath + localVariablePath
        let localVariableParameters = JSONEncodingHelper.encodingParameters(forEncodableObject: userWithdrawCreditsRequest)

        let localVariableUrlComponents = URLComponents(string: localVariableURLString)

        let localVariableNillableHeaders: [String: Any?] = [
            "Content-Type": "application/json",
            "x-api-key": xApiKey.encodeToJSON(),
        ]

        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)

        let localVariableRequestBuilder: RequestBuilder<UserWithdrawCreditsDataResponse>.Type = WinWinKitAPI.requestBuilderFactory.getBuilder()

        return localVariableRequestBuilder.init(method: "POST", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: false)
    }
}
