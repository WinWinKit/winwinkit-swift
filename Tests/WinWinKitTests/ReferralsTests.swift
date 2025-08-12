import Foundation
import Testing
@testable import WinWinKit

@Suite struct ReferralsTests {
    struct Dependencies {
        let apiKey: String
        let claimActionsProvider: MockClaimActionsProvider
        let networkReachability: MockNetworkReachability
        let offerCodeProvider: MockOfferCodesProvider
        let rewardActionsProvider: MockRewardActionsProvider
        let usersProvider: MockUsersProvider
        let userCache: UserCacheType
    }

    let dependencies: Dependencies
    let referrals: Referrals

    init() {
        self.dependencies = Dependencies(
            apiKey: MockConstants.apiKey,
            claimActionsProvider: MockClaimActionsProvider(),
            networkReachability: MockNetworkReachability(),
            offerCodeProvider: MockOfferCodesProvider(),
            rewardActionsProvider: MockRewardActionsProvider(),
            usersProvider: MockUsersProvider(),
            userCache: UserCache(keyValueCache: MockKeyValueCache())
        )
        self.referrals = Referrals(
            apiKey: self.dependencies.apiKey,
            networkReachability: self.dependencies.networkReachability,
            providers: .init(
                claimActions: self.dependencies.claimActionsProvider,
                offerCodes: self.dependencies.offerCodeProvider,
                rewardActions: self.dependencies.rewardActionsProvider,
                users: self.dependencies.usersProvider
            ),
            userCache: self.dependencies.userCache
        )
    }

    @Test func singletonInstanceIsSet() async throws {
        #expect(Referrals.isConfigured == false)
        let referrals = Referrals.configure(apiKey: MockConstants.apiKey)
        #expect(Referrals.shared === referrals)
        #expect(Referrals.isConfigured == true)
    }

    @Test func delegateIsNotRetained() {
        #expect(self.referrals.delegate == nil)
        let delegate = MockReferralsDelegate()
        self.referrals.delegate = delegate
        #expect(self.referrals.delegate === delegate)
        var weakDelegate: ReferralsDelegate?
        weakDelegate = MockReferralsDelegate()
        self.referrals.delegate = weakDelegate
        #expect(self.referrals.delegate === weakDelegate)
        weakDelegate = nil
        #expect(self.referrals.delegate == nil)
    }

    @Test func userProperty() {
        #expect(self.referrals.user == nil)
        let user1 = MockUser.mock(appUserId: "app-user-id-1")
        self.dependencies.userCache.user = user1
        #expect(self.referrals.user == nil)
        self.referrals.set(appUserId: user1.appUserId)
        #expect(self.referrals.user == user1)
        #expect(self.dependencies.userCache.userUpdate == nil)
        self.dependencies.userCache.user = nil
        #expect(self.referrals.user == nil)
        let user2 = MockUser.mock(appUserId: "app-user-id-2")
        self.dependencies.userCache.user = user2
        #expect(self.referrals.user == nil)
        self.referrals.set(appUserId: user2.appUserId)
        #expect(self.referrals.user == user2)
        self.referrals.set(appUserId: "app-user-id-3")
        #expect(self.referrals.user == nil)
    }

    @Test func setAppUserIdWhenNotReachable() async throws {
        #expect(self.referrals.user == nil)
        let user1 = MockUser.mock()
        self.referrals.set(appUserId: user1.appUserId)
        #expect(self.referrals.user == nil)
        #expect(self.dependencies.userCache.userUpdate?.appUserId == user1.appUserId)
        #expect(self.dependencies.networkReachability.startMethodCallsCounter == 1)
        #expect(self.dependencies.networkReachability.isReachableGetterCallsCounter == 1)
        #expect(self.dependencies.networkReachability.delegate != nil)
    }

    @Test func setAppUserIdWhenReachable() async throws {
        let user1 = MockUser.mock()
        self.dependencies.usersProvider.createOrUpdateUserResultToReturn = .success(UserResponseData(user: user1))
        self.dependencies.networkReachability.isReachable = true
        let delegate = MockReferralsDelegate()
        self.referrals.delegate = delegate
        self.referrals.set(appUserId: user1.appUserId)
        #expect(self.referrals.user == nil)
        #expect(self.dependencies.userCache.user == nil)
        #expect(self.dependencies.networkReachability.startMethodCallsCounter == 1)
        #expect(self.dependencies.networkReachability.isReachableGetterCallsCounter == 1)
        #expect(self.dependencies.networkReachability.delegate != nil)
        #expect(self.dependencies.usersProvider.createOrUpdateUserCallsCounter == 0)
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 0)
        try await Task.sleep(for: .milliseconds(50))
        #expect(self.referrals.user == user1)
        #expect(self.dependencies.userCache.user == user1)
        #expect(self.dependencies.networkReachability.startMethodCallsCounter == 1)
        #expect(self.dependencies.networkReachability.isReachableGetterCallsCounter == 1)
        #expect(self.dependencies.networkReachability.delegate != nil)
        #expect(self.dependencies.usersProvider.createOrUpdateUserCallsCounter == 1)
        #expect(self.dependencies.usersProvider.apiKey == self.dependencies.apiKey)
        #expect(self.dependencies.usersProvider.request?.appUserId == user1.appUserId)
        #expect(self.dependencies.usersProvider.request?.isPremium == nil)
        #expect(self.dependencies.usersProvider.request?.firstSeenAt == nil)
        #expect(self.dependencies.usersProvider.request?.metadata == nil)
        #expect(delegate.receivedUpdatedUserCallsCounter == 1)
        #expect(delegate.receivedErrorCallsCounter == 0)
    }

    @Test func setFirstSeenAtWhenNotReachable() async throws {
        #expect(self.referrals.user == nil)
        let user1 = MockUser.mock()
        let date = Date.now.addingTimeInterval(-100)
        self.referrals.set(appUserId: user1.appUserId)
        self.referrals.set(firstSeenAt: date)
        #expect(self.referrals.user == nil)
        #expect(self.dependencies.userCache.userUpdate?.appUserId == user1.appUserId)
        #expect(self.dependencies.userCache.userUpdate?.firstSeenAt?.timeIntervalSince1970.rounded() == date.timeIntervalSince1970.rounded())
    }

    @Test func suspendsIndefinitelyWhenUnauthorized() async throws {
        let user1 = MockUser.mock()
        let error = ErrorResponse.error(401, nil, nil, MockError(message: "Unauthorized"))
        self.dependencies.usersProvider.createOrUpdateUserResultToReturn = .failure(error)
        self.dependencies.networkReachability.isReachable = true
        let delegate = MockReferralsDelegate()
        self.referrals.delegate = delegate
        self.referrals.set(appUserId: user1.appUserId)
        try await Task.sleep(for: .milliseconds(50))
        #expect(self.referrals.user == nil)
        #expect(self.dependencies.userCache.user == nil)
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 1)
        #expect(delegate.receivedError as? ErrorResponse != nil)
        self.referrals.set(isPremium: true)
        #expect(delegate.receivedError as? ReferralsError == .suspendedIndefinitely)
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 2)
        delegate.receivedError = nil
        self.referrals.set(firstSeenAt: Date.now)
        #expect(delegate.receivedError as? ReferralsError == .suspendedIndefinitely)
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 3)
        delegate.receivedError = nil
        self.referrals.set(metadata: ["key": "value"])
        #expect(delegate.receivedError as? ReferralsError == .suspendedIndefinitely)
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 4)
        await #expect(throws: ReferralsError.suspendedIndefinitely) {
            try await self.referrals.claimCode(code: "XYZ123")
        }
        await #expect(throws: ReferralsError.suspendedIndefinitely) {
            try await self.referrals.withdrawCredits(key: "key", amount: 100)
        }
        await #expect(throws: ReferralsError.suspendedIndefinitely) {
            try await self.referrals.fetchOfferCode(offerCodeId: "offer-code-id")
        }
        #expect(delegate.receivedUpdatedUserCallsCounter == 0)
        #expect(delegate.receivedErrorCallsCounter == 4)
    }
}
