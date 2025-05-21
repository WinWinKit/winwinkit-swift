//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserService.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

import AnyCodable
import Foundation

final class UserService {
    let appUserId: String
    let apiKey: String
    let offerCodeProvider: OfferCodeProviderType
    let userCache: UserCacheType
    let userClaimActionsProvider: UserClaimActionsProviderType
    let userProvider: UserProviderType
    let userRewardActionsProvider: UserRewardActionsProviderType

    init(appUserId: String,
         apiKey: String,
         offerCodeProvider: OfferCodeProviderType,
         userCache: UserCacheType,
         userClaimActionsProvider: UserClaimActionsProviderType,
         userProvider: UserProviderType,
         userRewardActionsProvider: UserRewardActionsProviderType)
    {
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.offerCodeProvider = offerCodeProvider
        self.userCache = userCache
        self.userClaimActionsProvider = userClaimActionsProvider
        self.userProvider = userProvider
        self.userRewardActionsProvider = userRewardActionsProvider
    }

    weak var delegate: UserServiceDelegate?

    var cachedUser: User? {
        if let user = self.userCache.user,
           user.appUserId == self.appUserId
        {
            return user
        }
        return nil
    }

    func set(isPremium: Bool) {
        Logger.debug("UserService: Set isPremium value")
        self.cacheUserUpdate(
            self.pendingUserUpdate?.set(isPremium: isPremium) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: isPremium,
                           firstSeenAt: nil,
                           lastSeenAt: nil,
                           metadata: nil)
        )
    }

    func set(firstSeenAt: Date) {
        Logger.debug("UserService: Set firstSeenAt value")
        self.cacheUserUpdate(
            self.pendingUserUpdate?.set(firstSeenAt: firstSeenAt) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: nil,
                           firstSeenAt: firstSeenAt,
                           lastSeenAt: nil,
                           metadata: nil)
        )
    }

    func set(lastSeenAt: Date) {
        Logger.debug("UserService: Set lastSeenAt value")
        self.cacheUserUpdate(
            self.pendingUserUpdate?.set(lastSeenAt: lastSeenAt) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: nil,
                           firstSeenAt: nil,
                           lastSeenAt: lastSeenAt,
                           metadata: nil)
        )
    }

    func set(metadata: AnyCodable) {
        Logger.debug("UserService: Set metadata value")
        self.cacheUserUpdate(
            self.pendingUserUpdate?.set(metadata: metadata) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: nil,
                           firstSeenAt: nil,
                           lastSeenAt: nil,
                           metadata: metadata)
        )
    }

    var isRefreshing: Bool {
        self.refreshTask != nil
    }

    func refresh() {
        if self.shouldSuspendIndefinitely {
            Logger.debug("UserService: Refresh suspended indefinitely")
            return
        }

        if let delegate,
           !delegate.userServiceCanPerformNextRefresh(self)
        {
            Logger.debug("UserService: Refresh not allowed")
            return
        }

        if self.refreshTask != nil {
            Logger.debug("UserService: Refresh already in progress")
            return
        }

        self.refreshTask = Task { @MainActor in
            Logger.debug("UserService: Refresh will start")

            self.delegate?.userService(self, isRefreshingChanged: true)

            var completedSuccessfully = false

            do {
                let pendingUserUpdate = self.pendingUserUpdate
                let request = UserCreateRequest(
                    appUserId: self.appUserId,
                    isPremium: pendingUserUpdate?.isPremium,
                    firstSeenAt: pendingUserUpdate?.firstSeenAt,
                    lastSeenAt: pendingUserUpdate?.lastSeenAt,
                    metadata: pendingUserUpdate?.metadata
                )
                let updatedUser = try await self.userProvider.createOrUpdate(
                    request: request,
                    apiKey: self.apiKey
                )
                self.resetUserUpdate(with: pendingUserUpdate)
                self.cacheUser(updatedUser)

                completedSuccessfully = true

                Logger.debug("UserService: Refresh did finish")
            }
            catch {
                Logger.debug("UserService: Refresh did fail")
                Logger.error("Failed to refresh user: \(String(describing: error))")

                self.handleTaskError(error)
            }

            self.refreshTask = nil
            self.delegate?.userService(self, isRefreshingChanged: false)

            if completedSuccessfully && self.pendingUserUpdate != nil {
                Logger.debug("UserService: Refresh will start again")
                self.refresh()
            }
        }
    }

    var isClaimingCode: Bool {
        self.claimCodeTask != nil
    }

    func claim(referralCode code: String, completion: @escaping (Result<UserClaimReferralCodeResponse, Error>) -> Void) {
        if self.shouldSuspendIndefinitely {
            Logger.debug("UserService: Claim code suspended indefinitely")
            completion(.failure(ReferralsError.suspendedIndefinitely))
            return
        }

        if self.claimCodeTask != nil {
            Logger.debug("UserService: Claim code skipped because of already claiming code")
            completion(.failure(ReferralsError.actionAlreadyInProgress))
            return
        }

        self.claimCodeTask = Task { @MainActor in
            do {
                let request = UserClaimReferralCodeRequest(code: code)
                let userClaimReferralCodeResponse = try await self.userClaimActionsProvider.claim(
                    referralCode: request,
                    appUserId: self.appUserId,
                    apiKey: self.apiKey
                )

                Logger.debug("UserService: Claim code did finish")

                self.cacheUser(userClaimReferralCodeResponse.user)

                self.claimCodeTask = nil

                completion(.success(userClaimReferralCodeResponse))
            }
            catch {
                Logger.debug("UserService: Claim code did fail")
                Logger.error("Failed to claim code: \(String(describing: error))")

                self.handleTaskError(error)

                self.claimCodeTask = nil

                completion(.failure(error))
            }
        }
    }

    func withdraw(credits amount: Int, key: String, completion: @escaping (Result<UserWithdrawCreditsResponse, Error>) -> Void) {
        if self.shouldSuspendIndefinitely {
            Logger.debug("UserService: Withdraw credits suspended indefinitely")
            completion(.failure(ReferralsError.suspendedIndefinitely))
            return
        }

        Task { @MainActor in
            do {
                let request = UserWithdrawCreditsRequest(
                    key: key,
                    amount: Double(amount)
                )
                let userWithdrawCreditsResponse = try await self.userRewardActionsProvider.withdraw(
                    request: request,
                    appUserId: self.appUserId,
                    apiKey: self.apiKey
                )

                Logger.debug("UserService: Withdraw credits did finish")

                self.cacheUser(userWithdrawCreditsResponse.user)

                completion(.success(userWithdrawCreditsResponse))
            }
            catch {
                Logger.debug("UserService: Withdraw credits did fail")
                Logger.error("Failed to withdraw credits: \(String(describing: error))")

                self.handleTaskError(error)

                completion(.failure(error))
            }
        }
    }

    func fetchOfferCode(offerCodeId: String, completion: @escaping (Result<OfferCodeResponse, Error>) -> Void) {
        if self.shouldSuspendIndefinitely {
            Logger.debug("UserService: Fetch offer code suspended indefinitely")
            completion(.failure(ReferralsError.suspendedIndefinitely))
            return
        }

        Task { @MainActor in
            do {
                let offerCode = try await self.offerCodeProvider.fetch(offerCodeId: offerCodeId, apiKey: self.apiKey)

                Logger.debug("UserService: Fetch offer code did finish")

                completion(.success(offerCode))
            }
            catch {
                Logger.debug("UserService: Fetch offer code did fail")
                Logger.error("Failed to fetch offer code: \(String(describing: error))")

                self.handleTaskError(error)

                completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private(set) var shouldSuspendIndefinitely: Bool = false

    private var claimCodeTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    private var pendingUserUpdate: UserUpdate? {
        get {
            if let userUpdate = self.userCache.userUpdate,
               userUpdate.appUserId == self.appUserId
            {
                return userUpdate
            }
            return nil
        }
        set {
            self.userCache.userUpdate = newValue
        }
    }

    private func cacheUser(_ user: User) {
        self.userCache.user = user
        self.delegate?.userService(self, receivedUpdated: user)
    }

    private func cacheUserUpdate(_ userUpdate: UserUpdate) {
        self.userCache.userUpdate = userUpdate
    }

    private func resetUserUpdate(with user: UserUpdate?) {
        if self.userCache.userUpdate == user {
            self.userCache.userUpdate = nil
        }
    }

    private func handleTaskError(_ error: Error) {
        if let dispatcherError = error as? ErrorResponse,
           case let .error(status, _, _, _) = dispatcherError,
           status == 401
        {
            self.handleUnauthorizedError()
        }

        self.delegate?.userService(self, receivedError: error)
    }

    private func handleUnauthorizedError() {
        self.userCache.reset()
        self.shouldSuspendIndefinitely = true
        Logger.error("Authorization with the provided API key has failed! Please obtain a new API key and use it when initializing the Referrals object.")
    }
}
