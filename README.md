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
