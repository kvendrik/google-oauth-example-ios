# Google oAuth Example iOS

Example of oAuth authentication with multi-account support on iOS using [`GoogleSignIn`](https://github.com/google/GoogleSignIn-iOS) and [`GTMAppAuth`](https://github.com/google/GTMAppAuth).

## Why both libraries?
Reason we're using both libraries is because `GoogleSignIn` is Google's new preferred way of doing oAuth on iOS but it doesn't support multiple accounts to be logged in at the same time. To make that work we use a few methods from `GTMAppAuth` to save and load authorization objects to and from the keychain.

## Setup
1. [Create an oAuth client in Google's API Console](https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id)
2. Open `google-oauth-example.xcworkspace` in xCode (note that this project only supports iOS v15+ and therefor xCode v13+)
3. [Add the reversed client ID to your URL Types](https://developers.google.com/identity/sign-in/ios/start-integrating#add_a_url_scheme_for_google_sign-in_to_your_project)
4. Go to `GoogleAuth.swift` and replace `YOUR_OAUTH_CLIENT_ID` with your newly created client ID
5. Run the project in a simulator of your choice

## How it works

1. Load all saved authorizations from your keychain
```swift
GoogleAuth.shared.loadSavedAuthorizations() {
    print("loaded authorizations")
}
```

2. For new sign ins use `GoogleAuth.signIn`
```swift
googleAuth.signIn() {
    success in
    print(success ? "signed in" : "sign in failed")
}
```

3. Handle incoming URLs for when Google redirects back to your app after login
```swift
extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GoogleAuth.shared.handleUrl(url)
    }
}
```

4. Observe `GoogleAuth.shared` for changes in the logged in accounts

```swift
struct AccountsList: View {
    @ObservedObject var googleAuth = GoogleAuth.shared
    
    var body: some View {
        ForEach(googleAuth.profiles, id: \.self.email) {
            profile in
            Text(profile.email)
        }
    }
}
```

5. Log out accounts using their profile sub
```swift
GoogleAuth.shared.logOut(profile.sub)
```

6. Use `GoogleApi.fetch` for your own API requests
```swift
let profileSub = GoogleAuth.shared.profiles.first!.sub

guard let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo") else { return }

GoogleApi.shared.fetch(
    url: url,
    authorization: GoogleAuth.shared.authorizations[profileSub]!,
    dataStructure: GoogleProfile.self
) {
    profile, _ in

    guard let profile = profile else { return }

    print(profile)
}
```
