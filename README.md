# Referral program for mobile apps.

The official [WinWinKit](https://winwinkit.com) SDK for iOS and macOS.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/winwinkit/winwinkit-swift.git", exact: "0.2.0")
]
```

## Getting started

### Configure

Configure the SDK with API key and set the user's the App User Id.

```swift
import WinWinKit

Referrals.configure(apiKey: "your-api-key")
// Singleton can be used after configure(apiKey:) method has been called.
Referrals.shared.set(appUserId: "your-app-user-id")
```

**Set the First Seen At**

Recommended to set first seen at which is the date when the user was first seen in your app.
This is used to evaluate user's eligibility to claim code of another user. By default it is 7 days since the first seen at date. 

If not set, the first seen at is the date the user was created in WinWinKit.

```swift
Referrals.shared.set(firstSeenAt: Date())
```

### Update user properties

**Is Premium**

Update is premium property to track referring user's stats and enable rewards activation on conversion.

```swift
Referrals.shared.set(isPremium: true)
```

**Last Seen At**

Tracked automatically by the SDK. To disable auto tracking, set the `shouldAutoUpdateLastSeenAt` property to `false` before setting the `appUserId` property.

```swift
Referrals.shared.set(lastSeenAt: Date())
```

**Metadata**

Optionally set metadata to set user's additional properties.

```swift
Referrals.shared.set(metadata: ["key": "value"])
```

### User

User object contains all necessary information needed to display in the user interface.

Access the latest user object.

```swift
let user = Referrals.shared.user
```

> Also available as a property of `ReferralsObservableObject` (see below).

### Claim Referral Code

```swift
let (user, rewardsGranted) = try await Referrals.shared.claimReferralCode(code: "XYZ123")
 // Grant access to rewards in your app
```

### Fetch Offer Code with related Subscription

```swift
let (offerCode, subscription) = try await Referrals.shared.fetchOfferCode(offerCodeId: "1234-5678")
// Display to the user what benefits offer code gives
```

### Withdraw Credits
```swift
let (user, withdrawResult) = try await Referrals.shared.withdrawCredits(key: "extra-levels", amount: 5)
```

### SwiftUI

The SDK provides convenient `Observable` object to interact and observe changes in SwiftUI views.

**ReferralsObservableObject**

Provides observable `User` object, methods and states for interacting with WinWinKit service.

```swift
@State var referralsObservableObject = Referrals.shared.observableObject

...

VStack {
    Text("Your referral code")
    Text(self.referralsObservableObject.user?.code ?? "-")
      .font(.title3)
}

...

Button(action: {
    self.referralsObservableObject.claimReferralCode(code: self.code)
}) {
    Text("Claim")
}
```

> In SwiftUI only apps it is possible to build complete integration with only this observable object.

### User Interface

Currently, we **do not provide** pre-built UI components for presenting the referral program or claiming referral codes. We are actively working on adding these features in the near future.

### Delegate

Optionally set a delegate to receive events from the SDK.

```swift
let delegate = Delegate()
Referrals.shared.delegate = delegate

// Retain the delegate object to keep receiving events.

...


final class Delegate: ReferralsDelegate {
    
    init() {}

    func referrals(_ referrals: Referrals, receivedUpdated user: User?) {
        // Called every time the user is updated.
    }
    
    func referrals(_ referrals: Referrals, receivedError error: any Error) {
        // Received error when creating, updating or fetching the user.
    }
}

```

> Setting the delegate is optional when using observable object described below.

## Requirements

- iOS 16.0+
- macOS 13.0+
- Xcode 15.0+
- Swift 5.0+

## SDK Reference

Our full SDK reference _coming soon_.
