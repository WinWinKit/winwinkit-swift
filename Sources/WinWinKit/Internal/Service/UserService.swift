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
    let userCache: UserCacheType
    let userProvider: UserProviderType
    let userClaimActionsProvider: UserClaimActionsProviderType

    init(appUserId: String,
         apiKey: String,
         userCache: UserCacheType,
         userProvider: UserProviderType,
         userClaimActionsProvider: UserClaimActionsProviderType)
    {
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.userCache = userCache
        self.userProvider = userProvider
        self.userClaimActionsProvider = userClaimActionsProvider
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
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(isPremium: isPremium) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: isPremium,
                           firstSeenAt: nil,
                           lastSeenAt: nil,
                           metadata: nil)
        )
    }

    func set(firstSeenAt: Date) {
        Logger.debug("UserService: Set firstSeenAt value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(firstSeenAt: firstSeenAt) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: nil,
                           firstSeenAt: firstSeenAt,
                           lastSeenAt: nil,
                           metadata: nil)
        )
    }

    func set(lastSeenAt: Date) {
        Logger.debug("UserService: Set lastSeenAt value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(lastSeenAt: lastSeenAt) ??
                UserUpdate(appUserId: self.appUserId,
                           isPremium: nil,
                           firstSeenAt: nil,
                           lastSeenAt: lastSeenAt,
                           metadata: nil)
        )
    }

    func set(metadata: AnyCodable) {
        Logger.debug("UserService: Set metadata value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(metadata: metadata) ??
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
                let pendingUserUpdate = self.pendingReferralUserUpdate
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
                self.resetReferralUserUpdate(with: pendingUserUpdate)
                self.cacheReferralUser(updatedUser)

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

            if completedSuccessfully && self.pendingReferralUserUpdate != nil {
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
            return
        }

        if self.claimCodeTask != nil {
            Logger.debug("UserService: Claim code skipped because of already claiming code")
            return
        }

        self.claimCodeTask = Task { @MainActor in
            do {
                let request = UserClaimReferralCodeRequest(code: code)
                let referralClaimCodeData = try await self.userClaimActionsProvider.claim(referralCode: request,
                                                                                          appUserId: self.appUserId,
                                                                                          apiKey: self.apiKey)

                Logger.debug("UserService: Claim code did finish")

                self.cacheReferralUser(referralClaimCodeData.user)

                self.claimCodeTask = nil

                completion(.success(referralClaimCodeData))
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

    // MARK: - Private

    private var shouldSuspendIndefinitely: Bool = false

    private var claimCodeTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    private var pendingReferralUserUpdate: UserUpdate? {
        get {
            if let referralUser = self.userCache.userUpdate,
               referralUser.appUserId == self.appUserId
            {
                return referralUser
            }
            return nil
        }
        set {
            self.userCache.userUpdate = newValue
        }
    }

    private func cacheReferralUser(_ user: User) {
        self.userCache.user = user
        self.delegate?.userService(self, receivedUpdated: user)
    }

    private func cacheReferralUserUpdate(_ userUpdate: UserUpdate) {
        self.userCache.userUpdate = userUpdate
    }

    private func resetReferralUserUpdate(with user: UserUpdate?) {
        if self.userCache.userUpdate == user {
            self.userCache.userUpdate = nil
        }
    }

    private func handleTaskError(_ error: Error) {
        if let dispatcherError = error as? ErrorResponse {
            switch dispatcherError {
            case let .error(status, _, _, _):
                if status == 401 {
                    self.userCache.reset()
                    self.shouldSuspendIndefinitely = true

                    Logger.error("Authorization with the provided API key has failed! Please obtain a new API key and use it when initializing the Referrals object.")
                }
            }
        }

        self.delegate?.userService(self, receivedError: error)
    }
}
