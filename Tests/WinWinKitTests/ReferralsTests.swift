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
        let userCache: MockUserCache
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
            userCache: MockUserCache()
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
        #expect(self.dependencies.networkReachability.startMethodCallsCounter == 1)
        #expect(self.dependencies.networkReachability.isReachableGetterCallsCounter == 1)
        #expect(self.dependencies.networkReachability.delegate != nil)
    }

    @Test func setAppUserIdWhenReachable() async throws {
        let user1 = MockUser.mock()
        self.dependencies.usersProvider.createOrUpdateUserResultToReturn = .success(user1)
        self.dependencies.networkReachability.isReachable = true
        let delegate = MockReferralsDelegate()
        self.referrals.delegate = delegate
        #expect(self.referrals.user == nil)
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
        #expect(self.dependencies.usersProvider.request?.lastSeenAt != nil)
        #expect(self.dependencies.usersProvider.request?.metadata == nil)
        #expect(delegate.receivedUpdatedUserCallsCounter == 1)
        #expect(delegate.receivedErrorCallsCounter == 0)
    }
}
