//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserServiceTests.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import AnyCodable
import Testing
@testable import WinWinKit

@Suite struct ReferralUserServiceTests {
    @Test func initilization() {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        #expect(service.cachedUser == nil)
        #expect(service.delegate == nil)
    }

    @Test func cachedUser() {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        #expect(service.cachedUser == nil)
        userCache.user = MockUser.Full.object
        #expect(service.cachedUser == MockUser.Full.object)
        userCache.user = MockUser.Empty.object
        #expect(service.cachedUser == nil)
    }

    @Test func delegate() {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        #expect(service.delegate == nil)
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate
        #expect(service.delegate === delegate)
        var weakDelegate: UserServiceDelegate?
        weakDelegate = MockUserServiceDelegate()
        service.delegate = weakDelegate
        #expect(service.delegate === weakDelegate)
        weakDelegate = nil
        #expect(service.delegate == nil)
    }

    @Test func refreshFailsWithNoData() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == nil)
                }
            }

            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func refreshFailsWithNoDataAndHasNoFollowingRefresh() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)
                    #expect(service.cachedUser == nil)
                }
            }
            service.refresh()

            service.set(isPremium: true)

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func refreshFailsWithUnauthorized() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        userProvider.errorToThrow = ErrorResponse.error(401, nil, nil, MockError())
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == nil)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func refreshFailsAndResetsCacheWithUnauthorized() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        userCache.user = MockUser.Full.object
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        userProvider.errorToThrow = ErrorResponse.error(401, nil, nil, MockError())
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == nil)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func createReferralUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        userProvider.userToReturn = MockUser.Full.object
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("creates referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == MockUser.Full.object)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func updateReferralUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        userCache.user = MockUser.Full.object
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let updateMetadata: AnyCodable = ["value": 123]
        let updatedReferralUser = MockUser.Full.object.set(metadata: updateMetadata)
        userProvider.userToReturn = updatedReferralUser
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("updates referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == updatedReferralUser)
                }
            }
            service.set(metadata: updateMetadata)
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func createAndUpdateReferralUser() {}

    @Test func claimReferralCode() {}

    @Test func referralUserDeletedOnRemoteCreatesNewReferralUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        userCache.user = MockUser.Full.object
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let expectedReferralUser = MockUser.Full.object.set(metadata: nil)
        userProvider.userToReturn = expectedReferralUser
        let service = UserService(
            appUserId: MockUser.Full.object.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("creates new referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == expectedReferralUser)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }
}
