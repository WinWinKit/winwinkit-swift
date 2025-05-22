import Testing
@testable import WinWinKit

@Suite struct ReferralsTests {
    struct Dependencies {
        let userCache: MockUserCache
        let offerCodeProvider: MockOfferCodesProvider
        let claimActionsProvider: MockClaimActionsProvider
        let usersProvider: MockUsersProvider
        let rewardActionsProvider: MockRewardActionsProvider
    }

    let dependencies: Dependencies
    let referrals: Referrals

    init() {
        self.dependencies = Dependencies(
            userCache: MockUserCache(),
            offerCodeProvider: MockOfferCodesProvider(),
            claimActionsProvider: MockClaimActionsProvider(),
            usersProvider: MockUsersProvider(),
            rewardActionsProvider: MockRewardActionsProvider()
        )
        self.referrals = Referrals(
            apiKey: MockConstants.apiKey,
            networkReachability: MockNetworkReachability(),
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
}
