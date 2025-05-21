//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserServiceTests.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import AnyCodable
import Testing
@testable import WinWinKit

@Suite struct UserServiceTests {
    @Test func initilization() {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.appUserId,
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
            appUserId: MockUser.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        #expect(service.cachedUser == nil)
        userCache.user = MockUser.mock()
        #expect(service.cachedUser == MockUser.mock())
        userCache.user = nil
        #expect(service.cachedUser == nil)
    }

    @Test func delegate() {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let service = UserService(
            appUserId: MockUser.appUserId,
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
            appUserId: MockUser.appUserId,
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
            appUserId: MockUser.appUserId,
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
            appUserId: MockUser.appUserId,
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
        userCache.user = MockUser.mock()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        userProvider.errorToThrow = ErrorResponse.error(401, nil, nil, MockError())
        let service = UserService(
            appUserId: MockUser.appUserId,
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

    @Test func createUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        userProvider.userToReturn = MockUser.mock()
        let service = UserService(
            appUserId: MockUser.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("creates user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == MockUser.mock())
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func updateUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        userCache.user = MockUser.mock()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let updatedUser = MockUser.mock(metadata: ["value": 123])
        userProvider.userToReturn = updatedUser
        let service = UserService(
            appUserId: MockUser.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("updates user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == updatedUser)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test func createAndUpdateUser() {}

    @Test func claimReferralCode() {}

    @Test func fetchOfferCode() {}

    @Test func userDeletedOnRemoteCreatesNewUser() async throws {
        let offerCodeProvider = MockOfferCodeProvider()
        let userCache = MockUserCache()
        userCache.user = MockUser.mock()
        let userClaimActionsProvider = MockUserClaimActionsProvider()
        let userProvider = MockUserProvider()
        let expectedUser = MockUser.mock(code: "XYZ123")
        userProvider.userToReturn = expectedUser
        let service = UserService(
            appUserId: MockUser.appUserId,
            apiKey: MockConstants.apiKey,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
        let delegate = MockUserServiceDelegate()
        service.delegate = delegate

        try await confirmation("creates new user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()

                    #expect(userProvider.createOrUpdateMethodCallsCounter == 1)
                    #expect(userClaimActionsProvider.claimMethodCallsCounter == 0)

                    #expect(service.cachedUser == expectedUser)
                }
            }
            service.refresh()

            try await Task.sleep(for: .milliseconds(50))
        }
    }
}
