# Referral program for mobile apps.

The official [WinWinKit](https://winwinkit.com) SDK for iOS and macOS.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/winwinkit/winwinkit-swift.git", exact: "0.1.2")
]
```

## Getting started

### Configure

Configure the SDK with API key and set the referral user's the App User Id.

```swift
import WinWinKit

Referrals.configure(apiKey: "your-api-key")
Referrals.shared.set(appUserId: "your-app-user-id")
```

**Set the First Seen At**

Recommended to set first seen at which is the date when the user was first seen in your app.
This is used to evaluate user's eligibility to claim code of another user. By default it is 7 days since the first seen at date. 

If not set, the first seen at is the date the user was created in WinWinKit.

```swift
Referrals.shared.set(firstSeenAt: Date())
```

### Update referral user properties

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

Optionally set metadata to save user's additional properties.

```swift
Referrals.shared.set(metadata: ["key": "value"])
```

### User

User object contains all necessary information needed to display in the user interface.

Access the latest user object.

```swift
let user = Referrals.shared.user
```

> Also available as a property of `UserObservableObject` (see below).

### Claim code

Claim code object contains all necessary information needed to claim a code.

Access the latest claim code object.

```swift
Referrals.shared.claim(code: referralCode) { result in
    switch result {
        case .success(let (user, rewardsGranted)):
            // grant access to rewards in your app
        case .failure(let error):
            // handle error
    }
}
```

> Another way to claim code is to call the `claim` method of `ReferralClaimCodeObservableObject`.

### Delegate

Set a delegate to receive events from the SDK.

```swift
let delegate = Delegate()
Referrals.shared.delegate = delegate

// Retain the delegate object to keep receiving events.

...


final class Delegate: ReferralsDelegate {
    
    func referrals(_ referrals: Referrals, receivedUpdated user: User?) {
        // Called every time the referral user is updated.
    }
    
    func referrals(_ referrals: Referrals, receivedError error: any Error) {
        // Received error when creating, updating or fetching the referral user.
    }
    
    func referrals(_ referrals: Referrals, isRefreshingChanged isRefreshing: Bool) {
        // Called when internal refreshing state changes.
    }
}

```

> Setting the delegate is optional when using observable objects described below.

### SwiftUI

The SDK provides convenient `Observable` objects to observe changes to the referral user and claim code. 

**UserObservableObject**

Provides observable `User` and `isRefreshing` properties.

```swift
@State var userObservableObject = Referrals.shared.userObservableObject

...

VStack {
    Text("Your referral code")
    Text(self.userObservableObject.user?.code ?? "-")
      .font(.title3)
}
```

**ClaimReferralCodeObservableObject**

Provides observable `isClaimingCode`, `didClaimCodeSuccessfully`, `rewardsGranted` properties and `claim(code:)` method.

```swift
@State var claimReferralCodeObservableObject = Referrals.shared.claimReferralCodeObservableObject

...

Button(action: {
    self.claimReferralCodeObservableObject.claim(code: self.referralCode)
}) {
    Text("Claim referral code")
}
```
> In SwiftUI only apps it is possible to build complete integration with only these observable objects.

## Requirements

- iOS 16.0+
- macOS 13.0+
- Xcode 15.0+
- Swift 5.0+

## SDK Reference

Our full SDK reference _coming soon_.
